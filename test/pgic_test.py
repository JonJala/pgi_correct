"""
Unit tests of components in pgic.py.  This should be run via pytest
"""

import numpy as np
import pgs_correct.pgic as pgic
import pytest

###########################################

class TestCalculateRho:

    #########
    @pytest.mark.parametrize("h2, r2, expected_rho",
        [
        (1.0, 1.0, 1.0),
        (4.0, 1.0, 2.0),
        (1.0, 4.0, 0.5)
        ]
    )
    def test_happypath_noerrors(self, h2, r2, expected_rho):
        assert pgic.calculate_rho(h2, r2) == pytest.approx(expected_rho)

    #########
    @pytest.mark.parametrize("h2, r2, expected_error",
        [
        (0.0, 0.0, ZeroDivisionError),
        (1.0, 0.0, ZeroDivisionError),
        ]
    )
    def test_zero_r2_raises(self, h2, r2, expected_error):
        with pytest.raises(expected_error):
            pgic.calculate_rho(h2, r2)

    #########
    @pytest.mark.parametrize("h2, r2, expected_error",
        [
        ("abc", 1.0, TypeError),
        (1.0, "abc", TypeError)
        ]
    )
    def test_input_string_type_raises(self, h2, r2, expected_error):
        with pytest.raises(expected_error):
            pgic.calculate_rho(h2, r2)

    #########
    @pytest.mark.parametrize("h2, r2, expected_warning",
        [
        (-1.0, 1.0, RuntimeWarning),
        (1.0, -1.0, RuntimeWarning)
        ]
    )
    def test_input_negative_warns(self, h2, r2, expected_warning):
        with pytest.warns(expected_warning):
            pgic.calculate_rho(h2, r2)


###########################################

class TestCalculateCenterMatrix:

    #########
    @pytest.mark.parametrize("V_ghat, rho, z_int_mean, z_int_cov, expected_matrix",
        [
        (np.identity(5), 1.0, np.zeros(2), np.identity(2), np.identity(5)),
        (np.identity(5), 2.0, np.zeros(2), np.identity(2), np.diag([4, 4, 4, 1, 1])),
        (np.identity(5), 2.0, np.array([-2/3, -1/3]), np.array([[-10/9, 4/9], [4/9, -4/9]]),
            np.array([[-13.0, 6.0, 5.0, 0.0, 0.0], [6.0, -2.0, -2.0, 0.0, 0.0],
                      [5.0, -2.0, -1.0, 0.0, 0.0], [0.0, 0.0, 0.0, 1.0, 0.0],
                      [0.0, 0.0, 0.0, 0.0, 1.0]]))
        ]
    )
    def test_happypath_noerrors(self, V_ghat, rho, z_int_mean, z_int_cov, expected_matrix):
        assert np.allclose(pgic.calculate_center_matrix(V_ghat, rho, z_int_mean, z_int_cov),
                           expected_matrix)

    #########
    @pytest.mark.parametrize("V_ghat, rho, z_int_mean, z_int_cov, expected_error",
        [
        (np.identity(2), 0.0, np.zeros(2), np.identity(2), ZeroDivisionError),
        ]
    )
    def test_zero_rho_raises(self, V_ghat, rho, z_int_mean, z_int_cov, expected_error):
        with pytest.raises(expected_error):
            pgic.calculate_center_matrix(V_ghat, rho, z_int_mean, z_int_cov)

###########################################

class TestCalculateCorrectedCoefficients:

    #########
    @pytest.mark.parametrize("corr_matrix, coefficients, expected_coef",
        [
        (np.identity(5), np.zeros(5), np.zeros(5)),
        (np.identity(5), np.ones(5), np.ones(5)),
        (np.ones((5,5)), np.ones(5), np.full((5,5), 5))
        ]
    )
    def test_happypath_noerrors(self, corr_matrix, coefficients, expected_coef):
        assert np.allclose(pgic.calculate_corrected_coefficients(
            corr_matrix, coefficients), expected_coef)

    #########
    @pytest.mark.parametrize("corr_matrix, coefficients, expected_error",
        [
        (np.identity(5), np.ones(4), ValueError),
        ]
    )
    def test_dimension_mismatch_raises(self, corr_matrix, coefficients, expected_error):
        with pytest.raises(expected_error):
            pgic.calculate_corrected_coefficients(corr_matrix, coefficients)

###########################################

arg_to_flag_dict = {
    "" : "",
    " " : " ",
    "abc" : "abc",
    "ab_c" : "ab-c",
    "a_b_c" : "a-b-c" 
}
flag_to_arg_dict = {arg_to_flag_dict[arg] : arg for arg in arg_to_flag_dict}

test_arg_flag_pairs = list(arg_to_flag_dict.items())
test_flag_arg_pairs = list(flag_to_arg_dict.items())
test_args = list(arg_to_flag_dict.keys())
test_flags = list(flag_to_arg_dict.keys())

class TestToArgAndToFlag:

    #########
    @pytest.mark.parametrize("arg_str, expected_flag", test_arg_flag_pairs)
    def test_happypath_toflag_noerrors(self, arg_str, expected_flag):
        assert pgic.to_flag(arg_str) == expected_flag

    #########
    @pytest.mark.parametrize("flag_str, expected_arg", test_flag_arg_pairs)
    def test_happypath_toarg_noerrors(self, flag_str, expected_arg):
        assert pgic.to_arg(flag_str) == expected_arg

    #########
    @pytest.mark.parametrize("str_input", test_flags)
    def test_toflag_inverseof_toarg_noerrors(self, str_input):
        assert pgic.to_flag(pgic.to_arg(str_input)) == str_input

    #########
    @pytest.mark.parametrize("str_input", test_args)
    def test_toarg_inverseof_toflag_noerrors(self, str_input):
        assert pgic.to_arg(pgic.to_flag(str_input)) == str_input


###########################################

# TODO(jonbjala) Was just starting to write these tests when we had our meeting, so I'm just
# block commenting these for now.  If I can fit them in with the MVP delivery, then great, but if
# not, then it's not critical.

# test_gcta_base_settings = InternalNamespace()
# test_gcta_base_settings.pheno_file = None
# test_gcta_base_settings.bfile = None
# test_gcta_base_settings.gcta_exec = None
# test_gcta_base_settings.grm = None
# test_gcta_base_settings.grm_cutoff = 0.25

# class TestValidateGCTAInputs:

#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings",
#         [
#         ({})
#         ]
#         )
#     def test_nogcta_nogctaflags_noerrors(self, user_args, parsed_args, settings):
#         validate_gcta_inputs(user_args, parsed_args, settings)

#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings", [])
#     def test_gcta_allgctaflags_noerrors(self, user_args, parsed_args, settings):
#         validate_gcta_inputs(user_args, parsed_args, settings)


#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings", [])
#     def test_nogcta_withgctaflags_noforce_errors(self, user_args, parsed_args, settings):
#         settings.force = false
#         with pytest.raises(RuntimeError):
#             validate_gcta_inputs(user_args, parsed_args, settings)

#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings", [])
#     def test_nogcta_withgctaflags_withforce_errors(self, user_args, parsed_args, settings):
#         settings.force = true
#         validate_gcta_inputs(user_args, parsed_args, settings)  # TODO(check stderr for warning?)

#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings", [])
#     def test_gcta_missinggctaflags_errors(self, user_args, parsed_args, settings):
#         with pytest.raises(RuntimeError):
#             validate_gcta_inputs(user_args, parsed_args, settings)

#     #########
#     @pytest.mark.parametrize("user_args, parsed_args, settings", [])
#     def test_gcta_wrongexec_errors(self, user_args, parsed_args, settings):
#         with pytest.raises(NameError):
#             validate_gcta_inputs(user_args, parsed_args, settings)

###########################################
