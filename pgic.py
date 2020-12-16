#!/usr/bin/env python3

"""
Python tool to correct attenuation bias stemming from measurement error in polygenic scores (PGI).
"""

import argparse
import copy
import itertools
import logging
import multiprocessing
import os
import re
import stat
import sys
import tarfile
import tempfile
from typing import Any, Dict, List, Tuple
import zipfile

import numpy as np
import pandas as pd
import statsmodels.api as sm
import wget

####################################################################################################

# The default short file prefix to use for output and logs
DEFAULT_SHORT_PREFIX = "pgi_correct"

# Software version
__version__ = '0.0.2'

# Email addresses to use in header banner to denote contacts
SOFTWARE_CORRESPONDENCE_EMAIL1 = "grantgoldman0@gmail.com"
SOFTWARE_CORRESPONDENCE_EMAIL2 = "jjala.ssgac@gmail.com"
OTHER_CORRESPONDENCE_EMAIL = "paturley@broadinstitute.org"

# GCTA version used when downloading
GCTA_VERSION = "gcta_1.93.0beta"

# GCTA executable used when downloading
GCTA_EXEC = "gcta64"

# GCTA URL (where to try to download GCTA from)
GCTA_URL = "https://cnsgenomics.com/software/gcta/bin"

# BOLT version used when downloading
BOLT_VERSION = "BOLT-LMM_v.2.3.4"

# BOLT executable used when downloading
BOLT_EXEC = "bolt"

# BOLT URL (where to try to download BOLT from)
BOLT_URL = "http://data.broadinstitute.org/alkesgroup/BOLT-LMM/downloads"

# Default number of blocks for jack-knifing
DEFAULT_NUM_JK_BLOCKS = 100

# Threshold of number of jack knife blocks below which the user is warned
MIN_WARNING_JK_BLOCKS = 20

# Name given to column of constant values added to the regression data
CONS_COL_NAME = "cons"

# List holding CONS_COL_NAME (this software passes column names are passed around via lists)
CONS_COLS = [CONS_COL_NAME]

# Result reporting values
VAR_OUTPUT_COLUMN = "variable_name"
UNCORR_COEF_COLUMN = "uncorrected_coef"
UNCORR_COEF_SE_COLUMN = "uncorrected_se"
CORR_COEF_COLUMN = "corrected_coef"
CORR_COEF_SE_COLUMN = "corrected_se"
OUTPUT_COLUMNNAMES = [VAR_OUTPUT_COLUMN, UNCORR_COEF_COLUMN, UNCORR_COEF_SE_COLUMN,
                      CORR_COEF_COLUMN, CORR_COEF_SE_COLUMN]

####################################################################################################

DEFAULT_FULL_OUT_PREFIX = "%s/%s" % (os.getcwd(), DEFAULT_SHORT_PREFIX)

# Logging banner to use at the top of the log file
HEADER = """
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
<>
<> Polygenic Index (PGI) Measurement Error Correction
<> Version: %s
<> (C) 2020 Social Science Genetic Association Consortium (SSGAC)
<> MIT License
<>
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
<> Software-related correspondence: %s or %s
<> All other correspondence: %s
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
""" % (__version__, SOFTWARE_CORRESPONDENCE_EMAIL1, SOFTWARE_CORRESPONDENCE_EMAIL2,
       OTHER_CORRESPONDENCE_EMAIL)


# Formatted string to use for reporting to the log/terminal and also the results file
RESULTS_SUMMARY_FSTR = """
N = %s
Heritability = %s (%s)
R Squared = %s (%s)
Rho = %s (%s)
"""

# Used in the slot where standard errors would normally be reported (when jack-knife wasn't run)
ASSUMED_VAL = "assumed"


"""
Class used as a holder for internal values
"""
class InternalNamespace:
    pass


def warn_or_raise(force: Any, msg_str: str, *msg_args: Any):
    """
    If force is False-ish, this throws a runtime error with message msg_str.  Otherwise,
    it logs msg_str at a warning level.  The message msg_str can be a %-formatted string that
    takes arguments, which are passed via msg_args.

    :param force: Determines if this should raise an exception or log a warning
    :param msg_str: String to log or use as exception message
    :param *args: Optional positional arguments that are inputs to msg_str formatting
    """
    if not force:
        raise RuntimeError(msg_str % msg_args)
    logging.warning("WARNING: " + msg_str, *msg_args)


def set_up_logger(output_full_prefix: str, logging_level: str):
    """
    Set up the logger for this utility.

    :param output_full_prefix: Full prefix to use for output files
    :param logging_level: Level of verbosity of logging object.

    :return: Returns the full path to the log output file
    """

    # This bit of validation needs to be done early here so that the logger can be created
    output_dir = os.path.dirname(output_full_prefix)
    if not os.path.exists(output_dir):
        raise FileNotFoundError("The designated output directory [%s] does not exist." % output_dir)

    # Construct full path to desired log output file
    full_logfile_path = output_full_prefix + ".log"

    # Set stdout handler level
    logging_level_map = {"debug": logging.DEBUG,
                         "info": logging.INFO,
                         "warn": logging.WARN}
    if logging_level not in logging_level_map:
        raise ValueError("Logging level %s not recognized.  Please specify one of %s " %
                         (logging_level, list(logging_level_map.keys())))

    # Set logging config (message is timestamp plus text)
    logging.basicConfig(format='%(asctime)s %(message)s',
                        filename=full_logfile_path,
                        filemode='w', level=logging_level_map[logging_level], datefmt='%I:%M:%S %p')

    # Create extra handlers to mirror messages to the terminal
    # (errors and warnings to stderr and lower priority messages to stdout)
    stderr_handler = logging.StreamHandler(stream=sys.stderr)
    stderr_handler.setLevel(logging.WARNING)
    stdout_handler = logging.StreamHandler(stream=sys.stdout)
    stdout_handler.setLevel(logging_level_map[logging_level])
    stdout_handler.addFilter(lambda record: record.levelno <= logging.INFO)

    # Add the handlers to the logger
    logging.getLogger().addHandler(stderr_handler)
    logging.getLogger().addHandler(stdout_handler)

    return full_logfile_path


def to_flag(arg_str: str) -> str:
    """
    Utility method to convert from the name of an argparse Namespace attribute / variable
    (which often is adopted elsewhere in this code, as well) to the corresponding flag

    :param arg_str: Name of the arg

    :return: The name of the flag (sans "--")
    """

    return arg_str.replace("_", "-")


def to_arg(flag_str: str) -> str:
    """
    Utility method to convert from an argparse flag name to the name of the corresponding attribute
    in the argparse Namespace (which often is adopted elsewhere in this code, as well)

    :param flag_str: Name of the flag (sans "--")

    :return: The name of the argparse attribute/var
    """

    return flag_str.replace("-", "_")


def format_os_cmd(cmd: List[str]) -> str:
    """
    Format OS command for readability (used to display string used to execute this software)

    :param cmd: Command to be passed to os.system(.), stored as a list
                whose elements are the options/flags.

    :return: Formatted string.
    """

    return "Calling " + ' '.join(cmd).replace("--", " \\ \n\t--")


def validate_h2_software_inputs(user_args: Dict[str, str], parsed_args: argparse.Namespace,
                                settings: InternalNamespace):
    """
    Responsible for validating gcta/bolt flags for internal consistency and valid values
    (doesn't need to check for existence of files / directories, this is just for the flag values)

    :param user_args: User-specified flags
    :param parsed_args: Result of argparse parsing user command / flags
    :param settings: Internal namespace class
    """

    # Classify GCTA-related flags for checking consistency
    required_gcta_argnames = {"pheno_file"}
    need_one_argnames = {"bfile", "grm"}
    optional_gcta_argnames = {"gcta_exec", "grm_cutoff"} | need_one_argnames
    required_bolt_argnames = {"pheno_file", "bfile"}
    optional_bolt_argnames = {"pheno_file_pheno_col"}

    # Set of all user flags employed
    user_args_key_set = set(user_args.keys())
    all_software_args = required_gcta_argnames | optional_gcta_argnames | required_bolt_argnames | optional_bolt_argnames

    if settings.use_gcta:
        missing = required_gcta_argnames - user_args_key_set
        settings.software = "GCTA"
        exec_name = os.path.basename(parsed_args.gcta_exec) if parsed_args.gcta_exec else None
    else:
        missing = required_bolt_argnames - user_args_key_set
        settings.software = "BOLT"
        exec_name = os.path.basename(parsed_args.bolt_exec) if parsed_args.bolt_exec else None

    # Run different checks of flags depending on whether GCTA is needed or not
    if settings.calc_h2:
        # If all the required flags aren't specified, throw an exception
        if missing:
            raise RuntimeError("For %s to run, please specify the following missing flags: %s" %
                               (software, {to_flag(arg) for arg in missing}))

        # Check to make sure bfile or GRM are specified
        need_ones_present = need_one_argnames & user_args_key_set
        if len(need_ones_present) != 1 and settings.use_gcta:
            raise RuntimeError("Need to specify one and only one of: %s", need_one_argnames)

        # Issue a warning if GCTA is specified by the user and it's not the expected executable name
        if exec_name: # check if an executable has been passed first
            if exec_name != GCTA_EXEC and exec_name != BOLT_EXEC:
                raise NameError("Specified executable [%s] is not the expected one: [%s]" %
                                (exec_name, GCTA_EXEC if settings.use_gcta else BOLT_EXEC))
    else:
        # If any GCTA-related flags are specified, warn the user
        not_needed = [x for x in all_software_args if x in user_args_key_set]
        if not_needed:
            extraneous_flags = {to_flag(arg) for arg in not_needed}
            warn_or_raise(settings.force, "The following unneeded flags were specified: %s",
                          extraneous_flags)


def validate_filedir_inputs(user_args: Dict[str, str], parsed_args: argparse.Namespace,
                            settings: InternalNamespace):
    """
    Responsible for validating the existence of files and directories (not file contents)

    :param user_args: User-specified flags
    :param parsed_args: Result of argparse parsing user command / flags
    :param settings: Internal namespace class
    """

    # Check for output directory (somewhat redundant as the logging setup probably did this already)
    out_dir = os.path.dirname(parsed_args.out)
    if not os.path.exists(out_dir):
        raise FileNotFoundError("The designated output directory [%s] does not exist." % out_dir)
    settings.out_dir = out_dir

    # Check for regression data file
    if not os.path.exists(parsed_args.reg_data_file):
        raise FileNotFoundError("The designated data file [%s] does not exist." %
                                parsed_args.reg_data_file)

    # If path to gcta executable is specified (and gcta is needed), confirm it exists
    if settings.calc_h2 and parsed_args.gcta_exec:
        if not os.path.exists(parsed_args.gcta_exec):
            raise FileNotFoundError("The specified gcta executable [%s] does not exist." %
                                    args.gcta_exec)

    # If grm info is specified (and gcta is needed), confirm it all exists
    if settings.calc_h2 and parsed_args.grm:
        grm_dir = os.path.dirname(parsed_args.grm)
        if not os.path.exists(grm_dir):
            raise FileNotFoundError("The specified grm directory [%s] does not exist." % grm_dir)

        if not (os.path.exists("%s.grm.bin" % parsed_args.grm) and
                os.path.exists("%s.grm.id" % parsed_args.grm) and
                os.path.exists("%s.grm.N.bin" % parsed_args.grm)):
            raise FileNotFoundError("One or more of the expected GRM files "
                                    "(%s.grm.bin, %.grm.ID, and %s.grm.N) "
                                    "do not exist in directory %s." %
                                    (parsed_args.grm, parsed_args.grm, parsed_args.grm, grm_dir))

    # If a phenotype file is specified (and gcta is needed), confirm it exists
    if settings.calc_h2 and parsed_args.pheno_file:
        if not os.path.exists(parsed_args.pheno_file):
            raise FileNotFoundError("The designated phenotype file [%s] does not exist." %
                                    parsed_args.pheno_file)

    # If bfile directory/file info is specified (and gcta is needed), confirm it all exists
    if settings.calc_h2 and parsed_args.bfile:
        bfile_dir = os.path.dirname(parsed_args.bfile)
        if not os.path.exists(bfile_dir):
            raise FileNotFoundError("The specified bfile directory [%s] does not exist." %
                                    bfile_dir)

        if not (os.path.exists("%s.bed" % parsed_args.bfile) and
                os.path.exists("%s.bim" % parsed_args.bfile) and
                os.path.exists("%s.fam" % parsed_args.bfile)):
            raise FileNotFoundError("One or more of the expected bed/bim/fam files "
                                    "(%s.bed, %s.bim, and %s.fam) do not exist in directory %s." %
                                    (parsed_args.bfile, parsed_args.bfile,
                                     parsed_args.bfile, bfile_dir))


def validate_numeric_flags(user_args: Dict[str, str], parsed_args: argparse.Namespace,
                           settings: InternalNamespace):
    """
    Responsible for validating numeric flags (e.g. to confirm they are within required bounds)

    :param user_args: User-specified flags
    :param parsed_args: Result of argparse parsing user command / flags
    :param settings: Internal namespace class
    """

    # Include check for GRM cutoff here if bounds can be specified

    # Include check for weights if bounds can be specified

    # Check h^2 if it's specified
    h2_lower_bound = 0.0
    h2_upper_bound = 1.0
    if parsed_args.h2:
        if parsed_args.h2 < h2_lower_bound or parsed_args.h2 > h2_upper_bound:
            raise ValueError("The specified h^2 value (%s) should be between %f and %f." %
                             (parsed_args.h2, h2_lower_bound, h2_upper_bound))

    # Check R^2 if it's specified
    r2_lower_bound = 0.0
    r2_upper_bound = 1.0
    if parsed_args.R2:
        if parsed_args.R2 < r2_lower_bound or parsed_args.R2 > r2_upper_bound:
            raise ValueError("The specified R^2 value (%s) should be between %f and %f." %
                             (parsed_args.R2, r2_lower_bound, r2_upper_bound))

    # Check num blocks if it's specified
    if parsed_args.num_blocks:
        if parsed_args.num_blocks < 2:
            raise ValueError("The specified num-blocks (%s) is invalid" % parsed_args.num_blocks)

        if parsed_args.num_blocks < MIN_WARNING_JK_BLOCKS:
            warn_or_raise(settings.force, "The specified num-blocks (%s) should be at LEAST %f",
                          parsed_args.num_blocks, MIN_WARNING_JK_BLOCKS)


def validate_jackknife_inputs(user_args: Dict[str, str], parsed_args: argparse.Namespace,
                              settings: InternalNamespace):
    """
    Responsible for validating jack-knife-related flags for internal consistency

    :param user_args: User-specified flags
    :param parsed_args: Result of argparse parsing user command / flags
    :param settings: Internal namespace class
    """

    # Classify JK-related flags for checking consistency
    required_jk_argnames = {}
    optional_jk_argnames = {"num_blocks"}
    if settings.calc_h2:  # id_col is required if we need to run GCTA
        required_jk_argnames.add("id_col")
    else:
        optional_jk_argnames.add("id_col")

    if len(iargs.id_col) > 2:
        raise ValueError("Cannot specify more than two ID columns.")

    # Break down which flags the user set that are required and optional for GCTA to run
    user_args_key_set = set(user_args.keys())  # Set of all user flags employed
    all_jk_user_argnames = user_args_key_set & optional_jk_argnames  # Right now, all are optional

    # Run different checks of flags depending on whether JK is being run or not
    if settings.jk_se:
        # If all the required flags aren't specified, throw an exception
        missing_req_argnames = required_jk_argnames - user_args_key_set
        if missing_req_argnames:
            missing_flags = {to_flag(arg) for arg in missing_req_argnames}
            raise RuntimeError("For JK to run, please specify the following missing flags: %s" %
                               missing_flags)
    else:
        # If any JK-related flags are specified, warn the user
        if len(all_jk_user_argnames) != 0:
            extraneous_flags = {to_flag(arg) for arg in all_jk_user_argnames}
            warn_or_raise(settings.force, "The following unneeded flags were specified: %s",
                          extraneous_flags)


def validate_regression_data_columns(user_args: Dict[str, str], parsed_args: argparse.Namespace,
                                     settings: InternalNamespace):
    """
    Responsible for validating the inputs related to column names in the regression data

    :param user_args: User-specified flags
    :param parsed_args: Result of argparse parsing user command / flags
    :param settings: Internal namespace class
    """

    # Keep track of sets of columns to check (colname : error_val_user_for_checking_below)
    required = {"outcome" : True,
                "pgi_var" : True,
                "pgi_pheno_var" : False,
                "weights" : False,
                "id_col" : settings.jk_se,
                "pgi_interact_vars" : False,
                "covariates" : True}
    if "weights" in user_args:
        settings.weights = [settings.weights]

    # Read the first line of the file to get column names
    first_line_of_reg_data = pd.read_csv(parsed_args.reg_data_file, sep=None,
                                         engine='python', nrows=1)
    file_columns = set(first_line_of_reg_data.columns)
    logging.debug("Found the following columns in regression data: %s\n", file_columns)


    # Determine actual interaction and covariate column lists and record them to internal namespace
    for coltype in ["pgi_interact_vars", "covariates"]:
        pargs_val = getattr(parsed_args, coltype)
        if getattr(parsed_args, coltype):
            try:
                setattr(settings, coltype, determine_col_names_from_input(
                    pargs_val, file_columns, parsed_args.force))
            except:
                logging.error("Error matching columns for %s", to_flag(coltype))
                raise

    # Set pgi pheno var to outcome if not set already (and then disregard, just check outcome)
    if not parsed_args.pgi_pheno_var:
        settings.pgi_pheno_var = settings.outcome
        required.pop("pgi_pheno_var")

    # Check flags to make sure required ones are filled in and anything specified maps to a column
    col_sets = dict()
    for colarg in required:
        # Get the set of columns listed / mapped to for the given column type
        cols = set(getattr(settings, colarg))

        # Determine whether the list of columns for that type is empty or some don't map to file
        missing_cols = cols - file_columns
        not_specified = not cols

        # Run checks against the column type vis-a-vis whether it's required / has invalid values
        if missing_cols:
            # If any columns are specified, but are missing from the file column list,
            # throw unavoidable error
            raise LookupError("Could not find columns %s specified using the flag --%s "
                              "in the list of columns %s in the regression data file." %
                              (missing_cols, to_flag(colarg), file_columns))

        if not_specified:
            # If it's not specified but required, then throw an unavoidable error
            if required[colarg]:
                raise LookupError("No value(s) specified for needed flag --%s!" % to_flag(colarg))
        else:
            # Keep track of the set of file columns of the given type/arg
            col_sets[colarg] = cols

    # At this point, valid_coltypes only contains column arguments whose columns
    # actually exist in the regression file.  Now we need to check that some columns weren't
    # specified more than once (with the exception of covariates and pgi_interact_vars)

    # If covariates and pgi_interact_vars are both specified, check if pgi_interact_vars is a
    # subset of covariates, and, if not, warn or throw and error depending on --force
    if settings.pgi_interact_vars:
        extra_interact_vars = col_sets["pgi_interact_vars"] - col_sets["covariates"]
        if extra_interact_vars:
            warn_or_raise(settings.force, "There are interaction columns specified (%s) not in the "
                          "set of covariates", extra_interact_vars)


    # Check to make sure all remaining column sets pairs are disjoint
    for cols_pair in itertools.combinations(col_sets, 2):
        # Skip pgi_interact_vars and covariates comparison, which is a special case already handled
        if (cols_pair[0] == "pgi_interact_vars" and cols_pair[1] == "covariates") or (
                cols_pair[0] == "covariates" and cols_pair[1] == "pgi_interact_vars"):
            continue

        # Check to make sure the given pair is disjoint (if not, throw unavoidable error)
        col_intersection = col_sets[cols_pair[0]] & col_sets[cols_pair[1]]
        if col_intersection:
            raise LookupError("Columns listed for flag --%s and columns listed for flag --%s "
                              "share columns %s, and these sets must be disjoint." %
                              (to_flag(cols_pair[0]), to_flag(cols_pair[1]), col_intersection))

    # Log the covariates and interact columns found, depending on log level
    logging.debug("Identified the following covariate columns: %s", settings.covariates)
    logging.debug("Identified the following interaction columns: %s", settings.pgi_interact_vars)


def validate_inputs(pargs: argparse.Namespace, user_args: Dict):
    """
    Responsible for coordinating whatever initial validation of inputs can be done

    :param pargs: Result of argparse parsing user command / flags
    :param user_args: Flags explicitly set by the user along with their values

    :return: Dictionary that contains flags and parameters needed by this program.  It contains
             user-input flags along with defaults set through argparse, and any additional flags
             added as calculations proceed
    """

    # Create dictionary to be used as the internal store for flags and parameters
    settings = InternalNamespace()

    # Copy values from args to internal namespace (may be overwritten in the internal namespace)
    # Could this be done by just making a shallow copy of `pargs`?
    for attr in vars(pargs):
        setattr(settings, attr, getattr(pargs, attr))

    # Check if heritability calculation(s) required and which software to use
    settings.calc_h2 = not pargs.h2
    settings.use_gcta = settings.calc_h2 and "bolt_exec" not in user_args

    # Check if GCTA commands should have stdout suppressed
    settings.quiet_h2 = pargs.logging_level != "debug"

    # Check h^2 external software flags (should do this first to figure out if calc is needed, which
    #                                    affects later validation steps)
    validate_h2_software_inputs(user_args, pargs, settings)

    # Check numeric flags
    validate_numeric_flags(user_args, pargs, settings)

    # Check existence of files and directories
    validate_filedir_inputs(user_args, pargs, settings)

    # Check regression data column inputs
    validate_regression_data_columns(user_args, pargs, settings)

    return settings


def determine_col_names_from_input(exprs: List[str], cols: List[str], force: Any = False):
    """
    Takes a list of (possibly wildcarded) input column names and a list of actual column names
    and determines which, if any, actual column names are matches.  If any input column name
    expression does not match at least one actual column, an error is thrown (unless force is
    True-like, in which case a warning is logged for each unmatched expression).

    :param exprs: List of (possibly wildcarded) input expressions to map to the real column names
    :param cols: List of actual column names to match against
    :param force: Parameter to control whether an unmatched input results in a warning log or error

    :return A list of columns from cols that are matched by at least one member of exprs
    """

    # Create set of column names by matching against input expressions
    colname_set = set()
    for expr in exprs:
        # Collect any columns that match the given expr
        matching_cols = set(filter(lambda col: re.fullmatch(
            expr.replace("?", ".").replace("*", ".*"), col), cols))

        # If any match, add them to the accumulation set and move to the next expr
        if matching_cols:
            colname_set |= matching_cols
            continue

        # No column matched the given expr, either log a warning or throw an exception
        warn_or_raise(force, "Could not match any column name against column flag "
                      "value [%s]", expr)

    return list(colname_set)


def _get_parser(progname: str) -> argparse.ArgumentParser:
    """
    Return a parser configured for this command line utility

    :param prog: Value to pass to ArgumentParser for prog (should be sys.argv[0])

    :return: argparse ArgumentParser
    """
    parser = argparse.ArgumentParser(prog=progname)

    ifile = parser.add_argument_group(title="Input file specifications",
                                      description="Options for input files.")
    ifile.add_argument("--reg-data-file", metavar="FILE_PATH", type=str, required=True,
                       help="Full path to dataset where coefficients are to be corrected.  "
                            "Contains outcome, genetic data / PGI, (optional) interaction terms, "
                            "covariates, (optional) weights, and (if needed) IDs.")
    ifile.add_argument("--outcome", metavar="COLUMN_NAME", type=str, required=True, nargs=1,
                       help="Name of dependent variable column in regression data file.")
    ifile.add_argument("--pgi-var", metavar="COLUMN_NAME", type=str, required=True, nargs=1,
                       help="Name of PGI variable column in regression data file.")
    ifile.add_argument("--pgi-pheno-var", metavar="COLUMN_NAME", type=str, required=False, nargs=1,
                       default=[], help="Name of column in regression data file corresponding to "
                                        "the phenotype in the PGI.  If not specified, it is "
                                        "assumed to be the same column as the outcome column")
    ifile.add_argument("--pgi-interact-vars", metavar="COLUMN_NAME", type=str, required=False,
                       nargs="*", default=[], help="Names of columns from the regression data file "
                                                   "(separated by spaces, like VAR1 VAR2 VAR3) "
                                                   " that should be interacted with the pgi.  "
                                                   "NOTE: These columns are assumed to be "
                                                   "uninteracted on input!  This software will "
                                                   "handle the interaction!"
                                                   "Use \"*\" for a general wildcard and \"?\" for "
                                                   "a single wildcard character.  Regular "
                                                   "expressions are used to provide this "
                                                   "functionality, so limit column characters to "
                                                   "A-Z, a-z, 0-9, _, and -.  If wildcarding is "
                                                   "used, surround each term with quotes.")
    ifile.add_argument("--covariates", metavar="COLUMN_NAME", type=str, nargs="+", required=True,
                       help="Column names from the regression data file of covariates to "
                            "be included in the regression (separated by spaces, like "
                            "VAR1 VAR2 VAR3).  Use \"*\" for a general wildcard and \"?\" for a "
                            "single wildcard character.  Regular expressions are used to provide "
                            "this functionality, so limit column characters to A-Z, a-z, 0-9, _, "
                            "and -.  If wildcarding is used, surround each term with quotes.")
    ifile.add_argument("--weights", metavar="COLUMN_NAME", type=str, nargs="?", default=[],
                       help="Optional flag specifying a column name from regression data file "
                            "to be used for weighted least squares.")

    ofile = parser.add_argument_group(title="Output file specifications",
                                      description="Options for output files.")
    ofile.add_argument("--out", metavar="FILE_PREFIX", required=False,
                       default=DEFAULT_FULL_OUT_PREFIX,
                       help="Full prefix of output files (e.g. logs and results).  If not set, "
                            "[current working directory]/%s = \"%s\" will be used." %
                       (DEFAULT_SHORT_PREFIX, DEFAULT_FULL_OUT_PREFIX))
    ofile.add_argument("--output-vars", metavar="COLUMN_NAME", required=False, nargs="*",
                       help="To be used if only a subset of variables should be reported in the "
                            "results file.  Useful if controlling for many features but are only "
                            "interesting in seeing the output of a small number.  Specify as a "
                            "whitespace-delimited list of variables exactly as they appear in "
                            "your data.  If you want an interaction term in this list, append "
                            "\"_int\" to the corresponding covariate.  If not specified, "
                            "all independent variables will be reported.")

    paramopts = parser.add_argument_group(title="Optional parameter specifications",
                                          description="Choose to pre-specify h^2, R^2, and "
                                                      "relatedness cutoff.")
    paramopts.add_argument("--h2", metavar="PARAM", type=float, required=False,
                           help="Option to specify heritability of phenotype corresponding "
                                "to the PGI.  If not specified, GCTA will be run to calculate it.")
    paramopts.add_argument("--R2", metavar="PARAM", type=float, required=False,
                           help="Option to specify the R^2 from the regression of the PGI on its "
                           "corresponding phenotype.  If not specified, it will be calculated.")
    paramopts.add_argument("--grm-cutoff", metavar="PARAM", type=float, required=False,
                           default=.025, help="Relatedness cutoff for heritability estimation.  "
                                              "Used when heritability is calculated.  "
                                              "Defaults to 0.025.")

    h2software = parser.add_mutually_exclusive_group()
    h2software.add_argument("--gcta-exec", metavar="FILE_PATH", type=str, required=False,
                            help="Full path to GCTA64 software executable.  If this flag is not "
                                 "specified and GCTA is needed for heritability calculations, then it "
                                 "will be downloaded and extracted in a temporary directory that should "
                                 "be cleaned up after this software is finished running.")
    h2software.add_argument("--bolt-exec", metavar="FILE_PATH", type=str, required=False,
                            help="Full path to BOLT-LMM_v2.3.4 software executable. This flag is an alternative "
                                 "to the --gcta-exec option and should be used if you are estimating "
                                 "heritability over a large sample (BOLT is more robust to larger datasets "
                                 "than GCTA, but GCTA has better behavior on smaller inputs). The software "
                                 "will assume that GCTA will be used for heritability estimation unless "
                                 "a valid path to BOLT-LMM_v2.3.4 is supplied. The path should end at the bolt "
                                 "executable, ie /path/to/bolt/BOLT-LMM_V2.3.4/bolt.")

    h2download = parser.add_mutually_exclusive_group()
    h2download.add_argument("--download-gcta", action="store_true", default=False, required=False,
                            help="Use this flag to download GCTA for heritability estimation. ")
    h2download.add_argument("--download-bolt", action="store_true", default=False, required=False,
                            help="Use this flag to download BOLT-LMM for heritability estimation.")


    h2opts = parser.add_argument_group(title="Heritability estimation flags",
                                       description="Flags relevant to estimating heritability (h^2) "
                                                   "with either BOLT or GCTA. These flags are only needed "
                                                   "if you are **not** specifying the --h2 flag. If "
                                                   "neither executable is specified, GCTA will be used.")

    h2opts.add_argument("--grm", metavar="FILE_PREFIX", type=str, required=False,
                        help="Optional argument to pass full prefix (directory included) of a "
                             "pre-constructed GRM for GCTA heritability estimation "
                             "(does not include .grm.bin, .grm.ID, .grm.N suffixes).")
    h2opts.add_argument("--bfile", metavar="FILE_PREFIX", type=str, required=False,
                        help="Full prefix (directory included) of bed/bim/fam files to use in "
                             "heritability calculation "
                             "(does not include .bed, .bim, .fam suffixes)")
    h2opts.add_argument("--pheno-file", metavar="FILE_PATH", type=str, required=False,
                       help="Full path to phenotype file for heritability calculation. The "
                            "phenotype must correspond to the phenotype used in the "
                            "construction of the PGI. Familiarize yourself with GCTA, specifications "
                            "(https://cnsgenomics.com/software/gcta/#GREMLanalysis) and BOLT "
                            "specifications (https://alkesgroup.broadinstitute.org/BOLT-LMM/downloads/BOLT-LMM_v2.3.4_manual.pdf) "
                            "depending on which software you want used.")
    h2opts.add_argument("--pheno-file-pheno-col", metavar="COLUMN_NAME", type=str, required=False, default="PHENOTYPE",
                        help="Column name in --pheno-file that corresponds to the phenotype, if you are "
                             "using BOLT to estimate heritability. ")


    jkopts = parser.add_argument_group(title="Jack knife standard error specifcation",
                                       description="Jack knife SE flags.")
    jkopts.add_argument("--jk-se", required=False, action="store_true", help="Calculate jack-"
                        "knife standard errors for R^2, h^2, rho, and corrected alphas.")
    jkopts.add_argument("--num-blocks", required=False, type=int, default=DEFAULT_NUM_JK_BLOCKS,
                        help="Number of blocks to use for jack-knifing.  "
                             "Defaults to %s if not specified."  % DEFAULT_NUM_JK_BLOCKS)
    jkopts.add_argument("--id-col", required=False, nargs="*", metavar="COLUMN_NAME", default=[],
                        help="Column name(s) in regression data corresponding to person-level ID."
                             "This ID field must also correspond to the ID's in your "
                             "bed/bim/fam and phenotype files. If specifying an FID and IID, be sure "
                             "to pass the FID first.")

    controlopts = parser.add_argument_group(title="Control options",
                                            description="Flags related to program execution")
    controlopts.add_argument("--force", required=False, action="store_true",
                             help="Flag that causes the program to continue executing past many "
                                  "situations that ordinarily cause it to halt (e.g. specifying "
                                  "an interaction column that is not also a covariate)  This "
                                  "option is not recommended, but if it is employed, make sure "
                                  "to check the log / stderr for warnings to confirm that they "
                                  "are acceptable.")
    controlopts.add_argument("--logging-level", required=False, type=str.lower, default="info",
                             help="Level of verbosity of log file. One of \"debug\", \"info\", or "
                                  "\"warn\". The \"debug\" level will be the most verbose, giving "
                                  "detailed information at all levels of execution. The \"info\" "
                                  "level is the default and is recommended if you are confident "
                                  "in your specification.  Lastly, \"warn\" will print sparsely, "
                                  "only if something problematic is identified.")
    controlopts.add_argument("--num-threads", required=False, type=int, default=1,
                             help="Optional flag to specify the number of threads for GCTA operations."
                                  "Encouraged for GCTA/BOLT operations over large datasets. As a rule of "
                                  "thumb, do not specify more threads than cores in your machine.")
    return parser


def get_h2_software(dest_dir: str, gcta: bool = True) -> str:
    """
    Downloads and unzips h^2 software from internet.  Assumes the directory is temporary /
    this function is not required to clean up after itself.

    :param dest_dir: Destination directory specified by user to where GCTA will be downloaded.
    :param gcta: Indicator for whether or not GCTA should be installed (otherwise BOLT)

    :return: Full path to GCTA executable
    """

    if gcta:
        # Construct the expected full path to GCTA executable
        full_path_exec = "%s/%s/%s" % (dest_dir, GCTA_VERSION, GCTA_EXEC)

        # Determine zipfile name and then full path
        full_path_to_zipped_file = "%s/%s.zip" % (dest_dir, GCTA_VERSION)

        # Determine download URL and then fetch the file into the specified destination directory
        full_url = "%s/%s.zip" % (GCTA_URL, GCTA_VERSION)
    else:
        # Path to BOLT executable
        full_path_exec = "%s/%s/%s" % (dest_dir, BOLT_VERSION, BOLT_EXEC)

        # Zipfile full path
        full_path_to_zipped_file = "%s/%s.tar.gz" % (dest_dir, BOLT_VERSION)

        # BOLT URL
        full_url = "%s/%s.tar.gz" % (BOLT_URL, BOLT_VERSION)

    logging.info("Downloading %s...", full_url)
    wget.download(full_url, out=dest_dir)

    # read contents -- GCTA is zipped, BOLT is tarred (need to handle separately)
    file = zipfile.Zipfile(full_path_to_zipped_file) if gcta else tarfile.open(full_path_to_zipped_file)


    # Extract the zipfile to the destination directory
    try:
        file.extractall(path=dest_dir)

        # Set permissions on GCTA executable to allow for use
        os.chmod(full_path_exec, stat.S_IXUSR)

    except PermissionError:
        logging.error("Make sure you have the proper permissions to execute files in the "
                      "directory [%s].", dest_dir)
        raise

    logging.info("Successfully installed GCTA and updated permissions.")

    return full_path_exec


def get_user_inputs(argv: List[str], parsed_args: argparse.Namespace) -> str:
    """
    Create dictionary of user-specified options/flags and their values.  Leverages the argparse
    parsing output to glean the actual value, but checks for actual user-set flags in the input

    :param argv: Tokenized list of inputs (meant to be sys.argv in most cases)
    :param parsed_args: Result of argparse parsing the user input

    :return: Dictionary containing user-set args keyed to their values
    """

    # Search for everything beginning with "--" (flag names), strip off the --, take everything
    # before any "=", and convert - to _
    user_set_args = {to_arg(token[2:].split("=")[0]) for token in argv if token.startswith("--")}

    # Since any flag actually specified by the user shouldn't have been replaced by a default
    # value, one can grab the actual value from argparse without having to parse again
    return {user_arg:getattr(parsed_args, user_arg) for user_arg in user_set_args}


def estimate_h2(iargs: InternalNamespace, gcta_exec: str, pheno_file: str, temp_dir: str, grm_cutoff: float,
                grm_prefix: str, num_threads: int, suppress_stdout: Any = None) -> float:
    """
    Use GCTA to estimate SNP h^2, assumes GRM is available

    :param iargs: PGI arguments
    :param gcta_exec: Full path to GCTA executable
    :param pheno_file: Full path to phenotypic file.
    :param temp_dir: Full path to temporary directory to use for GCTA results
    :param grm_cutoff: Relatedness cutoff
    :param grm_prefix: Full prefix of GRM files
    :param num_threads: Number of threads for GCTA.
    :param suppress_stdout: If not False-ish, routes GCTA stdout to /dev/null

    :return: GCTA estimate of heritability
    """

    # Call GCTA to have it estimate heritability
    logging.info("\nEstimating heritability using %s..." % iargs.software)
    full_h_prefix = temp_dir + "/h2est"
    hlog_filename = full_h_prefix + ".log"
    if iargs.use_gcta:
        cmd_str = "%s --grm %s --pheno %s --reml --grm-cutoff %s --out %s --threads %s" \
                  % (gcta_exec, grm_prefix, pheno_file, grm_cutoff, full_h_prefix, num_threads)
        _log_and_run_os_cmd(cmd_str, suppress_stdout)
    else:
        cmd_str = "%s --reml --phenoFile=%s --phenoCol=%s --numThreads=%s --bfile=%s --maxModelSnps=2000000" \
                  % (iargs.bolt_exec, pheno_file, iargs.pheno_file_pheno_col, num_threads, iargs.bfile)
        # BOLT doesn't generate a log file so we need to capture stdout and put it in the right place
        cmd_str = cmd_str + " > %s" % full_h_prefix + ".log" if suppress_stdout else cmd_str + " | tee %s" % hlog_filename
        _log_and_run_os_cmd(cmd_str, False)


    # Scan the log file(s) to retrieve the value
    with open(hlog_filename, "r") as logfile:
        for line in logfile:
            if iargs.use_gcta:
                if "V(G)/Vp" in line:
                    heritability = float(line.split("\t")[1])
                    logging.debug("Estimated GCTA heritability of the trait is %f", heritability)
                    return heritability
            else:
                if "h2g (1,1):" in line:
                    heritability = line.split(":")[1].split(" ")[1]
                    logging.debug("Estimated BOLT heritability of the trait is %f", heritability)
                    return heritability

    raise LookupError("Could not find heritability in logfile: " + hlog_filename)


def _log_and_run_os_cmd(cmd_str: str, suppress_stdout: Any = None):
    """
    Function to run something from the command line (after logging the command)

    :param cmd_str: The command to run
    :param suppress_stdout: If not False-ish, send command std output to /dev/null
    """
    if suppress_stdout:
        cmd_str = cmd_str + " >/dev/null"
    logging.debug(format_os_cmd(cmd_str.split()))
    os.system(cmd_str)


def build_grm(gcta_exec: str, bfile_full_prefix: str, grm_dir: str, num_threads: int,
              suppress_stdout: Any = None) -> str:
    """
    Function to build GRM using GCTA.

    :param gcta_exec: Full path to GCTA executable
    :param bfile_full_prefix: Full prefix of bed/bim/fam files.
    :param grm_dir: Directory in which to place GRM files
    :param num_threads: Number of threads for GCTA operation.
    :param suppress_stdout: If not False-ish, sends GCTA std output to /dev/null

    :return: Full prefix of GRM files
    """

    # Determine full path prefix for the GRM
    grm_full_prefix = "%s/%s" % (grm_dir, DEFAULT_SHORT_PREFIX)

    # Direct GCTA to create the matrix
    cmd_str = "%s --bfile %s --make-grm --out %s --threads %s" %\
              (gcta_exec, bfile_full_prefix, grm_full_prefix, num_threads)
    _log_and_run_os_cmd(cmd_str, suppress_stdout)

    return grm_full_prefix



def estimate_R2(data: pd.DataFrame, pheno: List[str], pgi: List[str]) -> float:
    """
    Returns the R^2 from the regression of phenotype on PGI for the phenotype corresponding to the
    PGI.

    :param data: Pandas DataFrame containing phenotype and PGI.
    :param pheno: List containing column name in data corresponding to phenotype.
    :param pgi: List containing column name in data corresponding to PGI.

    :return: R^2 from regression of phenotype on PGI.
    """

    reg = sm.OLS(data[pheno], data[pgi + CONS_COLS])
    rsq = reg.fit().rsquared

    return rsq


def adjust_regression_data(orig_reg_data: pd.DataFrame, iargs: InternalNamespace) -> pd.DataFrame:
    """
    Performs fixes (not necessarily in this order):
        1) Add a constant to the dataset.
        2) Check for low variance columns.
        3) Remove NaN's.
        4) Standardize PGI
        5) Generate interaction columns
        6) Rearrange column order and omit unused columns

    :param orig_reg_data: Dataframe containing raw data
    :param iargs: Internal namespace for this software

    :return: Regression data processed as indicated above
    """

    # Determine the lists of columns in the adjusted dataframe
    # (make sure order of w's is the same as z_int)
    iargs.z_cols = iargs.covariates
    iargs.y_cols = iargs.outcome
    iargs.wt_cols = iargs.weights
    iargs.z_int_cols = iargs.pgi_interact_vars
    interact_dict = {z_int_col : (z_int_col+"_int") for z_int_col in iargs.z_int_cols}
    iargs.w_cols = [interact_dict[z_int_col] for z_int_col in iargs.z_int_cols]
    iargs.G_cols = iargs.pgi_var + iargs.w_cols
    iargs.alpha_cols = iargs.G_cols + iargs.z_cols

    # Create the (blank except for column-labels) adjusted dataframe
    reg_data_cols = iargs.alpha_cols + iargs.y_cols + CONS_COLS + iargs.wt_cols + iargs.id_col
    reg_data = pd.DataFrame(columns=reg_data_cols)

    # Copy y, z, and wts columns over as-is (side effect: sets the number of rows in the DF)
    for cols in [iargs.y_cols, iargs.z_cols, iargs.wt_cols, iargs.id_col]:
        for col in cols:
            reg_data[col] = orig_reg_data[col].to_numpy()

    # Copy the PGI to the new DF, standardizing it on the way
    g_col_name = iargs.pgi_var[0]
    g_mean = np.mean(orig_reg_data[g_col_name])
    g_std = np.std(orig_reg_data[g_col_name])
    if g_std == 0.0:
        raise ValueError("PGI column \"%s\" has variance zero!  Unable to proceed." %
                         g_col_name)
    stdized_pgi_vect = (orig_reg_data[g_col_name].to_numpy() - g_mean) / g_std
    reg_data[g_col_name] = stdized_pgi_vect

    # Generate the interaction (w) columns
    # (multiply the correct z_int column component-wise by PGI and copy to new table)
    for z_int_col in iargs.z_int_cols:
        reg_data[interact_dict[z_int_col]] = np.multiply(orig_reg_data[z_int_col].to_numpy(),
                                                         stdized_pgi_vect)

    # Set constant column (need to do that sometime after at least one other column is copied, so
    # the number of rows is determined)
    reg_data[CONS_COL_NAME] = 1

    # Drop any rows / individuals in data with NaN present as a value
    reg_data.dropna(inplace=True)

    # Check for 0 variance columns and raise error if any (other than CONS_COL_NAME) exist.
    var_of_col = dict(reg_data.var())
    zero_var_cols = {col_name for col_name in var_of_col if col_name != CONS_COL_NAME and
                     np.isclose(var_of_col[col_name], 0.0)}
    if zero_var_cols:
        raise ValueError("Column(s) %s in data has/have a very low variance.  "
                         "Please remove it to allow matrices to invert." % zero_var_cols)

    return reg_data


def se_helper(df: pd.DataFrame) -> pd.Series:
    """
    Calculates the standard errors for a set of jack-knife runs

    :param df: DataFrame where each row is a JK iteration

    :return: Series containing the JK standard errors
    """
    num_rows = len(df.index)
    return np.sqrt(float(num_rows - 1)) * df.std(axis=0, ddof=0)


def jack_knife_se(iargs: InternalNamespace, reg_data: pd.DataFrame, pgic_result: InternalNamespace):
    """
    1) Assign each person to a jack knife iteration.
    2) For each iteration:
            - restrict bfile, grm, regression data to people _not_ in block
            - estimate R^2, h^2, rho, alpha_{corr}
            - store results
    3) Calculate SE's using formula

    :param iargs: Internal namespace object that holds internal values and parsed user inputs
    :param reg_data: Dataframe containing regression data
    :param pgic_result: Internal namespace object that holds initial pgic results
    """

    logging.info("Beginning jack knife estimation.")

    # Check for a number of blocks that's too large
    if iargs.num_blocks > reg_data.shape[0]:
        raise ValueError("You cannot specify more jack knife blocks than there are people in "
                         "your --reg-data-file. You specified %s blocks, and your data is %s rows" %
                         (iargs.num_blocks, reg_data.shape[0]))

    # Label iterations and duplicate ID col to make GCTA happy (if needed)
    reg_data_shuf = reg_data.sample(frac=1).reset_index(drop=True)
    if iargs.calc_h2:
        reg_data_shuf["FID"] = reg_data_shuf[iargs.id_col[0]]
        # If a second ID column is specified, use that, otherwise the two ID columns are equivalent
        reg_data_shuf["IID"] = reg_data_shuf[iargs.id_col[1]]  if len(iargs.id_col) == 2 else \
                               reg_data_shuf.FID

    block_size = np.ceil(reg_data_shuf.shape[0] / iargs.num_blocks)
    reg_data_shuf["iteration"] = [int(i / block_size) for i in range(reg_data_shuf.shape[0])]

    # Gather results from each JK iteration
    uncorr_alpha_cols = ["uncorr_" + c for c in iargs.alpha_cols]
    corr_alpha_cols = ["corr_" + c for c in iargs.alpha_cols]
    result_cols = ["h2", "R2", "rho"] + uncorr_alpha_cols + corr_alpha_cols
    jk_res_table = pd.DataFrame(index=range(iargs.num_blocks), columns=result_cols)

    # Run the jack knife iterations
    for iter_num in range(iargs.num_blocks):
        iter_result = leave_out_est(iter_num, iargs, reg_data_shuf, iargs.grm, iargs.z_cols)
        h2_r2_rho = np.array([iter_result["h2"], iter_result["R2"], iter_result["rho"]])
        jk_res_table.iloc[iter_num] = np.concatenate(
            (h2_r2_rho, iter_result["alpha_uncorr"], iter_result["alpha_corr"]))
    logging.debug("\nJack-knife result table:\n%s", jk_res_table)

    # Calculate standard errors
    se_vector = se_helper(jk_res_table)
    logging.debug("\nJack-knife standard errors:\n%s", se_vector)

    # Fill in standard errors in the internal namespace object
    pgic_result.h2_se = None if iargs.h2 else se_vector["h2"]
    pgic_result.R2_se = None if iargs.R2 else se_vector["R2"]
    pgic_result.rho_se = None if iargs.h2 and iargs.R2 else se_vector["rho"]
    pgic_result.uncorrected_alphas_se = se_vector.loc[uncorr_alpha_cols]
    pgic_result.corrected_alphas_se = se_vector.loc[corr_alpha_cols].to_numpy()


def leave_out_est(iteration: int, iargs: InternalNamespace, reg_data: pd.DataFrame,
                  grm_prefix: str, covs: List) -> Dict:
    """
    Remove block from GRM and regression data and run estimation.  Uses temporary directory
    indicated in iargs and assumes no responsbility for cleanup

    :param iteration: Current block number of jack knife iteration.
    :param iargs: Internal namespace object that holds internal values and parsed user inputs
    :param reg_data: DataFrame of regression data.
    :param grm: Full prefix to GRM files
    :param covs: Covariates in specification.

    :return: Parameter estimates as a dictionary
    """

    logging.info("\n============= JK ITERATION %s =============\n", iteration)

    # Make copy of internal namespace
    iargs_copy = copy.copy(iargs)

    # If we need a restricted GRM, make that now
    if iargs.calc_h2:
        full_path_to_restricted_person_list = "%s/removed_%s.txt" % (iargs.temp_dir, iteration)
        full_prefix_to_restricted_grm = "%s/removed_grm_%s" % (iargs.temp_dir, iteration)

        remove = reg_data[reg_data.iteration == iteration]
        remove[["FID", "IID"]].to_csv(full_path_to_restricted_person_list, sep=" ",
                                      index=False, header=None)
        grm_transformation_cmd = "%s --grm %s --remove %s --out %s --make-grm --threads %s" % (
            iargs.gcta_exec, grm_prefix, full_path_to_restricted_person_list,
            full_prefix_to_restricted_grm, iargs.num_threads)
        _log_and_run_os_cmd(grm_transformation_cmd, iargs.quiet_h2)
        iargs_copy.grm = full_prefix_to_restricted_grm

    # Call the main procedure with a pared down dataframe and GRM (only included if it's needed)
    restricted_reg_data = reg_data[reg_data.iteration != iteration]
    iargs_copy.reg_data_file = None
    corr_result = error_correction_procedure(iargs_copy, restricted_reg_data)

    # Return the results in dictionary form
    return {"h2" : corr_result.h2, "R2" : corr_result.R2, "rho" : corr_result.rho,
            "alpha_corr" : corr_result.corrected_alphas,
            "alpha_uncorr" : corr_result.uncorrected_alphas}


def calculate_corrected_coefficients(corr_matrix: np.ndarray,
                                     coefficients: np.ndarray) -> np.ndarray:
    """
    Generates corrected coefficients from a correction matrix and uncorrected coefficients

    :param corr_matrix: Correction matrix to use
    :param coefficients: Coefficients to be corrected

    :return: Array of corrected coefficients
    """

    return np.matmul(corr_matrix, coefficients)


def calculate_corrected_coeff_stderrs(corr_matrix: np.ndarray,
                                      var_cov_matrix: np.ndarray) -> np.ndarray:
    """
    Generates corrected coefficient standard errors

    :param corr_matrix: Correction matrix to use
    :param var_cov_matrix: Variance-covariance matrix of coefficients to correct

    :return: Array of corrected coefficient standard errors
    """

    prod = np.linalg.multi_dot([corr_matrix, var_cov_matrix, corr_matrix.T])

    return np.sqrt(np.diagonal(prod))



def calculate_center_matrix(V_ghat: np.ndarray, rho: float, z_int_mean: np.ndarray,
                            z_int_cov: np.ndarray) -> np.ndarray:
    """
    Calculates the center matrix component of the product that is the final correction matrix.

    :param V_ghat: Covariance matrix of [G, z]
    :param rho: Value of rho to use
    :param z_int_mean: Mean of z_int
    :param z_int_cov: Covariance matrix of z_int

    :return: Center matrix to use in correction matrix product
    """

    # Calculate values used later
    rho_sq_recip = pow(rho, -2)
    one_minus_rho_sq_recip = 1.0 - rho_sq_recip
    z_int_count = z_int_cov.shape[0] if z_int_cov.shape else 1 # Shape is () if 1x1 matrix

    # Take V_ghat, replace (0,0) entry with 1/rho^2, and modify the rest of the matrix as needed
    mod_copy_of_V_ghat = V_ghat.copy()

    mod_copy_of_V_ghat[0, 0] = rho_sq_recip

    mod_copy_of_V_ghat[0, 1:z_int_count+1] -= (one_minus_rho_sq_recip * z_int_mean)
    mod_copy_of_V_ghat[1:z_int_count+1, 0] = mod_copy_of_V_ghat[0, 1:z_int_count+1].T

    mod_copy_of_V_ghat[1:z_int_count+1, 1:z_int_count+1] -= one_minus_rho_sq_recip * (z_int_cov +
                                                            np.outer(z_int_mean, z_int_mean))

    # Return inverse of the previously calculated matrix
    logging.debug("\nuninverted center matrix = \n%s", mod_copy_of_V_ghat)
    return np.linalg.inv(mod_copy_of_V_ghat)


def calculate_correction_matrix(G_cols: List[str], z_cols: List[str], z_int_cols: List[str],
                                df: pd.DataFrame, rho: float) -> np.ndarray:
    """
    Generates the correction matrix

    :param G_cols: List of columns in G vector = pgi_var column followed by interaction columns
    :param z_cols: List of columns in z vector = covariate columns
    :param z_int_cols: List of z columns that correspond (in order) to the non-pgi elements of G
    :param df: DataFrame with the required regression data
    :param rho: Value of rho

    :return: Matrix used to correct coefficients and standard errors
    """

    # Determine the needed relevant smaller DFs from column subsets
    df_Gz = df[G_cols + z_cols]
    df_z_int = df[z_int_cols]

    # Useful values
    size_of_G = len(G_cols)

    # Calculate the V_ghat matrix (rightmost matrix of the 3-matrix product)
    V_ghat = np.cov(df_Gz, rowvar=False)
    logging.debug("\nV_ghat = \n%s", V_ghat)

    # Calculate center matrix (start with V_ghat, since it shares much of that matrix)
    z_int_mean = np.mean(df_z_int, axis=0)
    logging.debug("\nz_int_mean = \n%s", z_int_mean)
    z_int_cov = np.cov(df_z_int, rowvar=False)
    logging.debug("\nz_int_cov = \n%s", z_int_cov)
    center_matrix = calculate_center_matrix(V_ghat, rho, z_int_mean, z_int_cov)
    logging.debug("\ncenter_matrix = \n%s", center_matrix)

    # Calculate the correction matrix
    corr_matrix = np.matmul(center_matrix, V_ghat)   # Almost correct, needs one more multiplication
    corr_matrix[0:size_of_G] *= np.reciprocal(rho) # Adjust to account for lefthand matmul
    logging.debug("\nCorrection matrix = \n%s", corr_matrix)

    return corr_matrix


def get_alpha_ghat(y_cols: List[str], G_cols: List[str], z_cols: List[str], wt_cols: List[str],
                   reg_data: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Runs the regression to get the initial estimate of coefficients and standard errors

    :param y_cols: List containing the name of the outcome column
    :param G_cols: List of columns in G vector = pgi_var column followed by interaction columns
    :param z_cols: List of columns in z vector = covariate columns
    :param wt_cols: List containing the weights column if the regression should be weighted
    :param reg_data: DataFrame with the required regression data

    :return: Calculated coefficients, standard errors, and variance-covariance matrix
    """

    # Set up the regression
    if wt_cols:
        reg = sm.WLS(reg_data[y_cols], reg_data[G_cols + z_cols + CONS_COLS], weights=reg_data[wt_cols])
    else:
        reg = sm.OLS(reg_data[y_cols], reg_data[G_cols + z_cols + CONS_COLS])

    # Calculate the regression
    reg_fit = reg.fit()

    return (reg_fit.params.drop(CONS_COL_NAME).rename(UNCORR_COEF_COLUMN, inplace=True),
            reg_fit.bse.drop(CONS_COL_NAME).rename(UNCORR_COEF_SE_COLUMN, inplace=True),
            reg_fit.cov_params().drop(CONS_COL_NAME).drop(CONS_COL_NAME, axis=1))


def error_correction_procedure(iargs: InternalNamespace, reg_data: pd.DataFrame):
    """
    Implementation of error correction procedure.

    :param iargs: Holds arguments passed in by user.
    :param reg_data: Regression data.

    :return: Object holding corrected and uncorrected coefficients and standard errors along with
             rho, h^2, R^2, and sample size (n)
    """

    # Create object to hold all the return values
    result = InternalNamespace()

    # If heritability is specified, add it to results, otherwise estimate it.
    result.h2 = iargs.h2 if iargs.h2 else estimate_h2(iargs, iargs.gcta_exec, iargs.pheno_file, iargs.temp_dir,
                                                      iargs.grm_cutoff, iargs.grm, iargs.num_threads,
                                                      iargs.quiet_h2)
    # Store sample size of data to report in results.
    result.n = reg_data.shape[0]

    # Determine R^2 (calculate if necessary)
    result.R2 = iargs.R2 if iargs.R2 else estimate_R2(reg_data, iargs.pgi_pheno_var, iargs.pgi_var)

    # Calculate rho based on h^2 and R^2
    result.rho = calculate_rho(h2=result.h2, r2=result.R2)
    logging.debug("rho is estimated to be sqrt(%f/%f) = %f", result.h2, result.R2, result.rho)
    if result.rho < 1.0:
        warn_or_raise(iargs.force, "It is unexpected that your estimated rho (%f) = sqrt(%f/%f) "
            "is less than 1.0.  You should double-check that the dependent variable in the R^2 "
            "calculation corresponds to the PGI phenotype.", result.rho, result.h2, result.R2)

    # Calculate initial regression values
    logging.debug("Calculating uncorrected coefficients(s) and standard error(s)...")
    result.uncorrected_alphas, result.uncorrected_alphas_se, var_cov_matrix = get_alpha_ghat(
        iargs.y_cols, iargs.G_cols, iargs.z_cols, iargs.wt_cols, reg_data)

    # Calculate the correction matrix
    logging.debug("Getting correction matrix...")
    corr_matrix = calculate_correction_matrix(iargs.G_cols, iargs.z_cols, iargs.z_int_cols,
                                              reg_data, result.rho)

    # Use that correction matrix to correct coefficients and standard errors
    logging.debug("Correcting coefficients and standard error(s)...")
    result.corrected_alphas = calculate_corrected_coefficients(corr_matrix,
                                                               result.uncorrected_alphas)
    result.corrected_alphas_se = calculate_corrected_coeff_stderrs(corr_matrix, var_cov_matrix)

    # Set standard errors for h^2, R^2, and rho to be None (need jack-knifing to calculate those)
    result.h2_se = None
    result.R2_se = None
    result.rho_se = None

    return result


def calculate_rho(h2: float, r2: float) -> float:
    """
    Helper function used to calculate rho given h^2 and R^2

    :param h2: Heritability
    :param r2: Coefficient of determination
    """

    return np.sqrt(h2 / r2)


def report_results(iargs: InternalNamespace, pgic_result: InternalNamespace):
    """
    Function that handles logging results and writing them to a results file

    :param iargs: Internal namespace of values directly or indirectly from parsed inputs
    :param pgic_result: Results from the initial running of the pgi correction method
    """

    # Determine output file
    full_outputfile_path = iargs.out + ".res"

    # Make standard error names a little shorter
    h2_se = pgic_result.h2_se
    R2_se = pgic_result.R2_se
    rho_se = pgic_result.rho_se
    uncorr_alphas_se = pgic_result.uncorrected_alphas_se
    corr_alphas_se = pgic_result.corrected_alphas_se

    # Construct results summary string
    results_summary = RESULTS_SUMMARY_FSTR % (pgic_result.n,
                                              pgic_result.h2,
                                              h2_se if h2_se else ASSUMED_VAL,
                                              pgic_result.R2,
                                              R2_se if R2_se else ASSUMED_VAL,
                                              pgic_result.rho,
                                              rho_se if rho_se else ASSUMED_VAL)

    # Send results summary to the log file, terminal, and .res file
    logging.info("\n\nResults summary:\n%s\n", results_summary)
    with open(full_outputfile_path, mode='w') as out_file:
        print(results_summary, "="*20, '\n', sep='\n', file=out_file)


    # Log and then write the coefficient results to the .res file
    out_data = pd.DataFrame(columns=OUTPUT_COLUMNNAMES)
    out_data[VAR_OUTPUT_COLUMN] = pgic_result.uncorrected_alphas.index
    out_data[UNCORR_COEF_COLUMN] = pgic_result.uncorrected_alphas.to_numpy()
    out_data[UNCORR_COEF_SE_COLUMN] = uncorr_alphas_se.to_numpy()
    out_data[CORR_COEF_COLUMN] = pgic_result.corrected_alphas
    out_data[CORR_COEF_SE_COLUMN] = corr_alphas_se

    # Sort data
    sortd = iargs.output_vars if iargs.output_vars else iargs.alpha_cols
    out_data = pd.DataFrame({"variable_name": sortd}).merge(out_data, on="variable_name")

    # Log data and push data to results file
    logging.info(out_data.to_string(index=False))
    out_data.to_csv(full_outputfile_path, sep="\t", index=False, mode='a')

    logging.info("Check output file [%s] for recorded results, including corrected coefficients.",
                 full_outputfile_path)


def main_func(argv: List[str]):
    """
    Main function that should handle all the top-level processing for this program
    (other than argument parsing, which takes place beforehand)

    :param argv: List of arguments passed to the program (meant to be sys.argv)
    """

    # Parse the input flags using argparse
    parser = _get_parser(argv[0])
    parsed_args = parser.parse_args(argv[1:])

    # Break down inputs to keep track of arguments and values pecified directly by the user
    user_args = get_user_inputs(argv, parsed_args)

    # Set up the logger
    full_logfile_path = set_up_logger(parsed_args.out, parsed_args.logging_level)

    # Log main header and passed-in flags (include full command at debug level)
    logging.info(HEADER)
    logging.info("See full log at: %s\n", full_logfile_path)
    logging.info(format_os_cmd(argv))

    # Validate inputs
    iargs = validate_inputs(parsed_args, user_args)

    # Enclose the rest of the code in a try-catch block to have some insurance that, if a
    # temporary directory is made, that it can be cleaned up
    try:
        # Possibly make a temporary directory (needed for heritability and/or jack-knife processing)
        if iargs.calc_h2 or iargs.jk_se:
            temp_dir_object = tempfile.TemporaryDirectory(dir=iargs.out_dir)
            iargs.temp_dir = temp_dir_object.name

        # Read in and clean/filter regression data
        logging.info("Loading regression data into memory...")
        reg_data = adjust_regression_data(
            pd.read_csv(iargs.reg_data_file, sep=None, engine='python'), iargs)
        logging.info("Read in data for %s individuals.\n", len(reg_data.index))

        # If h^2 software is needed, make sure it is available and calculate a GRM if need be
        if iargs.calc_h2:
            if iargs.download_gcta:
                logging.info("Retrieving GCTA...")
                iargs.gcta_exec = get_h2_software(iargs.temp_dir, iargs.use_gcta)
            if iargs.download_bolt:
                logging.info("Retrieving BOLT-LMM...")
                iargs.bolt_exec = get_h2_software(iargs.temp_dir, False)
            if not iargs.grm and iargs.use_gcta:
                logging.info("Constructing GRM using GCTA...")
                iargs.grm = build_grm(iargs.gcta_exec, iargs.bfile,
                                      iargs.temp_dir, iargs.num_threads, iargs.quiet_h2)

        logging.info("You've specified %d covariates to control for.", len(iargs.covariates))
        logging.info("You've specified %d interaction variables.", len(iargs.pgi_interact_vars))

        # Run the error correction method
        pgic_result = error_correction_procedure(iargs, reg_data)

        # Jack-knife if needed
        if iargs.jk_se:
            jack_knife_se(iargs, reg_data, pgic_result)

        # Report results (mixture of logging and sending output to the results file)
        report_results(iargs, pgic_result)

    except:
        # Try to clean up the temporary directory object (if it exists) to make sure it is
        # handled in the case of an exception
        try:
            temp_dir_object.cleanup()
        except Exception as e:
            pass
        raise


if __name__ == "__main__":

    # Call the main function
    try:
        main_func(sys.argv)
    except Exception as e:
        # If an exception is raised, log it, so that it shows up in the log and to stderror,
        # but stop it here so it is not sent to stderr a second time.  Exit with failure code
        logging.exception(e)
        sys.exit(1)
