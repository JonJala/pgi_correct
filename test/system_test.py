"""
End-to-end tests of the error correction software.  This should be run via pytest.
"""

import numpy as np
import pandas as pd
import logging
import os

import pytest
import tempfile

import pgs_correct.pgic as pgic

test_directory = os.path.dirname(__file__)
data_directory = os.path.join(test_directory, 'data')
full_path_to_pgic_exec = os.path.abspath(os.path.join(test_directory, '../pgic.py'))

@pytest.fixture(scope="module")
def temp_test_dir():
    with tempfile.TemporaryDirectory(dir=os.getcwd()) as t:
        yield t


def get_rho(log: str) -> float:
    """
    Extract rho from logfile path.

    :param log: Path to PGI log.
    :return: Value of rho.
    """
    with open(log, "r") as logfile:
        for line in logfile:
            if "Rho = " in line:
                return float(line.split("=")[1].split("(")[0])
    return None

#===================================================================================================

def test_pgic_gendata_mean0z_unncorrzg_gw_scales_by_rho(temp_test_dir, request):
    """
    Simulate a PGI, pheno, and an uncorrelated covariate and assert that the coefficient on the PGI
    scales by rho.
    """

    # Get/Generate directory and filename information
    testname = request.node.name
    out_prefix = os.path.join(temp_test_dir, testname)
    datfile_name = out_prefix + ".dat"
    logfile_name = out_prefix + ".log"
    resfile_name = out_prefix + ".res"

    ## GENERATE DATA
    corr = np.random.uniform(0, 0.2, 1)[0]
    data = np.random.multivariate_normal([np.random.uniform(0, 1, 1)[0] for _ in range(2)] + [0],
                                         [[1, np.sqrt(corr), 0], [np.sqrt(corr), 1, 0], [0, 0, 1]],
                                         size=10000)
    pgi, pheno, cov = data[:,0], data[:,1], data[:,2]
    df = pd.DataFrame({"pgi": pgi, "pheno": pheno, "cov": cov})
    df.to_csv(datfile_name, sep=" ", index=None)

    # Ensure that the heritability will be larger than the correlation
    h2 = corr + np.random.uniform(corr, (1 - corr) / 4, 1)[0]

    ## CALL PACKAGE
    os.system("python3 %s --reg-data-file %s --outcome pheno --pgi-interact-vars cov"
              " --pgi-var pgi --h2 %s --covariates cov --out %s" %
              (full_path_to_pgic_exec, datfile_name, h2, out_prefix))

    ## CHECK RESULTS
    # Get rho directly from the log file for most accurate comparison
    # (will be very close to sqrt(corr/h2)).
    rho = get_rho(logfile_name)

    results = pd.read_csv(resfile_name, skiprows=9, sep="\t")

    # Get the actual ratio for the PGI coefficient
    corr_pgi_coef = float(results[results.variable_name == "pgi"].corrected_coef)
    uncorr_pgi_coef = float(results[results.variable_name == "pgi"].uncorrected_coef)
    changed_coef_ratio = corr_pgi_coef / uncorr_pgi_coef

    # Here is the test
    err_msg = "PGI coefficient scaled by %f, not expected %f (= rho)" % (rho, changed_coef_ratio)
    assert np.abs(changed_coef_ratio - rho) < 0.01, err_msg  # TODO(jonbjala) Do we want an absolute difference check?  Or a relative difference?  Or even check if the ratio of scaling / rho is close to 1.0?


def test_pgic_gendata_scaledg_correctedequal(temp_test_dir, request):
    """
    Assert that PGI covariate stays the same if PGI is scaled.
    """

    # Get/Generate directory and filename information
    testname = request.node.name
    out_prefix = os.path.join(temp_test_dir, testname)
    datfile_name = out_prefix + ".dat"
    out_prefix1 = out_prefix + "_1"
    out_prefix2 = out_prefix + "_2"
    resfile1_name = out_prefix1 + ".res"
    resfile2_name = out_prefix2 + ".res"

    corr = np.random.uniform(0, 0.2, 1)[0]
    data = np.random.multivariate_normal([np.random.uniform(0, 1, 1)[0] for _ in range(3)],
                                         [[1, np.sqrt(corr), 0], [np.sqrt(corr), 1, 0], [0, 0, 1]],
                                         size=10000)
    pgi, pheno, cov = data[:,0], data[:,1], data[:,2]
    pgi2 = np.random.uniform(1, 10, 1)[0]*pgi # scale by an arbitrary amount
    df = pd.DataFrame({"pgi1": pgi, "pheno": pheno, "cov": cov, "pgi2": pgi2})
    df.to_csv(datfile_name, sep=" ", index=None)

    h2 = corr + np.random.uniform(corr, (1 - corr) / 4, 1)[0]
    # call on first PGI
    os.system("python3 %s --reg-data-file %s --outcome pheno --pgi-var pgi1 --h2 %s "
              "--covariates cov --out %s" % (full_path_to_pgic_exec, datfile_name, h2, out_prefix1))
    # call on second PGI
    os.system("python3 %s --reg-data-file %s --outcome pheno --pgi-var pgi1 --h2 %s "
              "--covariates cov --out %s" % (full_path_to_pgic_exec, datfile_name, h2, out_prefix2))

    resulta = list(pd.read_csv(resfile1_name,
                               skiprows=9, sep="\t").drop("variable_name", axis=1).loc[1])
    resultb = list(pd.read_csv(resfile2_name,
                               skiprows=9,sep="\t").drop("variable_name", axis=1).loc[1])
    # results should be indistinguishable
    assert np.isclose(resulta, resultb).all(), "The scaled PGS did not produce equivalent results."


def test_error_correction_mean0z_unncorrzg_gw_scales_by_rho():

    # Test parameters
    g = np.array([-1, -1, 0, 1, 1])  # Already standardized (unbiased)
    z = np.array([-1, 1, 0, -1, 1])  # Mean 0, uncorrelated with g
    e = np.array([0, 0, np.sqrt(5.0), 0, 0]) # Error / noise
    h2 = 1.0

    # Columns calculated from test parameters
    n = z.shape[0]
    w = g * z
    y = g + z + w + e
    cons = np.ones(n)

    # Construct the DataFrame to hold the data
    df_data = np.array([g, w, z, y, cons])
    df = pd.DataFrame(data=df_data.T, columns=["g", "w", "z", "y", "cons"])

    # Construct the InternalNamespace to hold the rest of the data / inputs
    iargs = pgic.InternalNamespace()
    iargs.G_cols = ["g", "w"]
    iargs.y_cols = ["y"]
    iargs.z_cols = ["z"]
    iargs.z_int_cols = ["z"]
    iargs.wt_cols = []
    iargs.pgi_pheno_var = iargs.y_cols
    iargs.pgi_var = ["g"]
    iargs.R2 = pgic.estimate_R2(df, iargs.pgi_pheno_var, iargs.pgi_var)
    iargs.h2 = h2

    # Run error correction procedure
    res = pgic.error_correction_procedure(iargs, df)

    # Check results
    assert res.n == n
    assert np.isclose(res.h2, iargs.h2)
    assert np.isclose(res.R2, iargs.R2)
    assert np.isclose(res.rho, np.sqrt(res.h2 / res.R2))
    assert np.isclose(res.corrected_alphas[0], res.uncorrected_alphas[0] * res.rho) # g
    assert np.isclose(res.corrected_alphas[1], res.uncorrected_alphas[1] * res.rho) # w
    assert np.isclose(res.corrected_alphas[2], res.uncorrected_alphas[2]) # z
    assert np.isclose(res.corrected_alphas_se[0], res.uncorrected_alphas_se[0] * res.rho) # g_se
    assert np.isclose(res.corrected_alphas_se[1], res.uncorrected_alphas_se[1] * res.rho) # w_se
    assert np.isclose(res.corrected_alphas_se[2], res.uncorrected_alphas_se[2]) # z_se


def test_error_correction_expected_corrected_all_ones(caplog):

    caplog.set_level(logging.DEBUG)

    # Test parameters
    r_gz = np.sqrt(0.5)
    num_people = 10 ** 7
    g = np.random.normal(size=num_people)
    h2 = 1.0
    R2 = 0.5

    # Columns calculated from test parameters
    z1 = 1.0 + r_gz * g + np.sqrt(1.0 - r_gz ** 2) * np.random.normal(size=num_people)
    z2 = 1.0 + r_gz * g + np.sqrt(1.0 - r_gz ** 2) * np.random.normal(size=num_people)
    gz1 = g * z1
    gz2 = g * z2
    y = 1.0 + g + gz1 + gz2 + z1 + z2 + np.random.normal(size=num_people) * 0.1
    g_hat_unstd = g + np.random.normal(size=num_people)
    g_hat = (g_hat_unstd - np.mean(g_hat_unstd)) / np.std(g_hat_unstd)
    w1 = g_hat * z1
    w2 = g_hat * z2
    cons = np.ones(num_people)

    # Construct the DataFrame to hold the data
    df_data = np.array([g_hat, w1, w2, z1, z2, y, cons])
    df = pd.DataFrame(data=df_data.T, columns=["g_hat", "w1", "w2", "z1", "z2", "y", "cons"])

    # Construct the InternalNamespace to hold the rest of the data / inputs
    iargs = pgic.InternalNamespace()
    iargs.G_cols = ["g_hat", "w1", "w2"]
    iargs.y_cols = ["y"]
    iargs.z_cols = ["z1", "z2"]
    iargs.z_int_cols = ["z1", "z2"]
    iargs.wt_cols = []
    iargs.pgi_pheno_var = iargs.y_cols
    iargs.pgi_var = ["g_hat"]
    iargs.R2 = R2
    iargs.h2 = h2

    # Run error correction procedure
    res = pgic.error_correction_procedure(iargs, df)

    # Check results
    assert res.n == num_people
    assert np.isclose(res.h2, iargs.h2)
    assert np.isclose(res.R2, iargs.R2)
    assert np.isclose(res.rho, np.sqrt(res.h2 / res.R2))
    assert np.isclose(res.corrected_alphas[0], 1.0, rtol=0.01, atol=0.01) # g_hat
    assert np.isclose(res.corrected_alphas[1], 1.0, rtol=0.01, atol=0.01) # w1
    assert np.isclose(res.corrected_alphas[2], 1.0, rtol=0.01, atol=0.01) # w2
    assert np.isclose(res.corrected_alphas[3], 1.0, rtol=0.01, atol=0.01) # z1
    assert np.isclose(res.corrected_alphas[4], 1.0, rtol=0.01, atol=0.01) # z2


def test_error_correction_mean0z_unncorrzg_gw_jackknife_expected_results(temp_test_dir):

    # Test parameters
    g = np.array([-1, -1, 0, 1, 1])  # Already standardized (unbiased)
    z = np.array([-1, 1, 0, -1, 1])  # Mean 0, uncorrelated with g
    e = np.array([0, 0, np.sqrt(5.0), 0, 0]) # Error / noise
    h2 = 1.0

    # Columns calculated from test parameters
    n = z.shape[0]
    w = g * z
    y = g + z + w + e
    cons = np.ones(n)
    iid = list(range(n))
    fid = iid

    # Construct the DataFrame to hold the data
    df_data = np.array([g, w, z, y, cons, iid, fid])
    df = pd.DataFrame(data=df_data.T, columns=["g", "w", "z", "y", "cons", "IID", "FID"])

    # Construct the InternalNamespace to hold the rest of the data / inputs
    iargs = pgic.InternalNamespace()
    iargs.G_cols = ["g", "w"]
    iargs.y_cols = ["y"]
    iargs.z_cols = ["z"]
    iargs.z_int_cols = ["z"]
    iargs.alpha_cols = iargs.G_cols + iargs.z_cols
    iargs.wt_cols = []
    iargs.id_col = ["IID"]
    iargs.pgi_pheno_var = iargs.y_cols
    iargs.pgi_var = ["g"]
    iargs.R2 = pgic.estimate_R2(df, iargs.pgi_pheno_var, iargs.pgi_var)
    iargs.h2 = h2
    iargs.jk_se = True
    iargs.num_blocks = 5
    iargs.grm = None
    iargs.temp_dir = temp_test_dir
    iargs.calc_h2 = False

    # Run error correction procedure and then jackknife
    res = pgic.error_correction_procedure(iargs, df)
    pgic.jack_knife_se(iargs, df, res)

    # Check results
    assert res.n == n
    assert np.isclose(res.h2, iargs.h2)
    assert np.isclose(res.R2, iargs.R2)
    assert np.isclose(res.rho, np.sqrt(res.h2 / res.R2))
    assert np.isclose(res.corrected_alphas[0], res.uncorrected_alphas[0] * res.rho) # g
    assert np.isclose(res.corrected_alphas[1], res.uncorrected_alphas[1] * res.rho) # w
    assert np.isclose(res.corrected_alphas[2], res.uncorrected_alphas[2]) # z
    assert not res.h2_se
    assert not res.R2_se
    assert not res.rho_se
    assert np.allclose(res.uncorrected_alphas_se, 4.0)
    # TODO(jonbjala) Might want to hand-check the corrected SE results
    assert np.allclose(res.corrected_alphas_se, [2.275482, 1.885789, 1.707598])


def test_jk(temp_test_dir, request):  # TODO(jonbjala) Needs renaming / better description, and some asserts
    testname = request.node.name
    data_filename = os.path.join(data_directory, 'reg_data.txt')
    bfile_full_prefix = os.path.join(data_directory, 'fake_data')
    phen_filename = os.path.join(data_directory, 'fake_pheno.phen')
    out_prefix = os.path.join(temp_test_dir, testname)

    os.system("python3 %s --reg-data-file %s "
                         "--bfile %s "
                         "--jk-se "
                         "--pheno-file %s "
                         "--outcome PHENO "
                         "--pgi-var PGI "
                         "--covariates PC* "
                         "--num-blocks 20 "
                         "--out %s "
                         "--force "
                         "--id-col IID "
                         "--grm-cutoff 1 "
                         "--logging-level debug" %
                         (full_path_to_pgic_exec, data_filename, bfile_full_prefix, phen_filename,
                         out_prefix))
