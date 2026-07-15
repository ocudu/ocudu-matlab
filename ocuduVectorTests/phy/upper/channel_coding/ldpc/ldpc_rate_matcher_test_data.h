// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#pragma once

// This file was generated using the following MATLAB class on 15-07-2026 (seed 0):
//   + "ocuduLDPCRateMatcherUnittest.m"

#include "ocudu/ran/sch/modulation_scheme.h"
#include "ocudu/support/file_vector.h"

namespace ocudu {

struct test_case_t {
  unsigned             rm_length  = 0;
  unsigned             rv         = 0;
  modulation_scheme    mod_scheme = {};
  unsigned             n_ref      = 0;
  bool                 is_lbrm    = false;
  unsigned             nof_filler = 0;
  file_vector<uint8_t> full_cblock;
  file_vector<uint8_t> rm_cblock;
};

static const std::vector<test_case_t> ldpc_rate_matcher_test_data = {
    // clang-format off
  {277, 0, modulation_scheme::BPSK, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input0.dat"}, {"test_data/ldpc_rate_matcher_test_output0.dat"}},
  {554, 1, modulation_scheme::QPSK, 700, true, 28, {"test_data/ldpc_rate_matcher_test_input1.dat"}, {"test_data/ldpc_rate_matcher_test_output1.dat"}},
  {924, 2, modulation_scheme::QAM16, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input2.dat"}, {"test_data/ldpc_rate_matcher_test_output2.dat"}},
  {4620, 3, modulation_scheme::QAM64, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input3.dat"}, {"test_data/ldpc_rate_matcher_test_output3.dat"}},
  {9240, 0, modulation_scheme::QAM256, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input4.dat"}, {"test_data/ldpc_rate_matcher_test_output4.dat"}},
  {210, 1, modulation_scheme::QAM1024, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input5.dat"}, {"test_data/ldpc_rate_matcher_test_output5.dat"}},
  {420, 0, modulation_scheme::QAM16, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input6.dat"}, {"test_data/ldpc_rate_matcher_test_output6.dat"}},
  {700, 3, modulation_scheme::BPSK, 700, true, 12, {"test_data/ldpc_rate_matcher_test_input7.dat"}, {"test_data/ldpc_rate_matcher_test_output7.dat"}},
  {3500, 2, modulation_scheme::QPSK, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input8.dat"}, {"test_data/ldpc_rate_matcher_test_output8.dat"}},
  {6996, 1, modulation_scheme::QAM64, 700, false, 12, {"test_data/ldpc_rate_matcher_test_input9.dat"}, {"test_data/ldpc_rate_matcher_test_output9.dat"}},
  {920, 0, modulation_scheme::QAM1024, 700, true, 28, {"test_data/ldpc_rate_matcher_test_input10.dat"}, {"test_data/ldpc_rate_matcher_test_output10.dat"}},
  {3496, 0, modulation_scheme::QAM256, 700, false, 12, {"test_data/ldpc_rate_matcher_test_input11.dat"}, {"test_data/ldpc_rate_matcher_test_output11.dat"}},
  {920, 1, modulation_scheme::QAM256, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input12.dat"}, {"test_data/ldpc_rate_matcher_test_output12.dat"}},
  {3500, 1, modulation_scheme::BPSK, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input13.dat"}, {"test_data/ldpc_rate_matcher_test_output13.dat"}},
  {276, 2, modulation_scheme::QAM64, 700, true, 28, {"test_data/ldpc_rate_matcher_test_input14.dat"}, {"test_data/ldpc_rate_matcher_test_output14.dat"}},
  {420, 2, modulation_scheme::BPSK, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input15.dat"}, {"test_data/ldpc_rate_matcher_test_output15.dat"}},
  {9240, 2, modulation_scheme::QAM1024, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input16.dat"}, {"test_data/ldpc_rate_matcher_test_output16.dat"}},
  {210, 3, modulation_scheme::QPSK, 700, false, 0, {"test_data/ldpc_rate_matcher_test_input17.dat"}, {"test_data/ldpc_rate_matcher_test_output17.dat"}},
  {552, 3, modulation_scheme::QAM256, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input18.dat"}, {"test_data/ldpc_rate_matcher_test_output18.dat"}},
  {7000, 3, modulation_scheme::QAM16, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input19.dat"}, {"test_data/ldpc_rate_matcher_test_output19.dat"}},
  {9240, 0, modulation_scheme::BPSK, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input20.dat"}, {"test_data/ldpc_rate_matcher_test_output20.dat"}},
  {700, 0, modulation_scheme::QPSK, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input21.dat"}, {"test_data/ldpc_rate_matcher_test_output21.dat"}},
  {9240, 2, modulation_scheme::QPSK, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input22.dat"}, {"test_data/ldpc_rate_matcher_test_output22.dat"}},
  {208, 1, modulation_scheme::QAM16, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input23.dat"}, {"test_data/ldpc_rate_matcher_test_output23.dat"}},
  {4620, 0, modulation_scheme::QAM16, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input24.dat"}, {"test_data/ldpc_rate_matcher_test_output24.dat"}},
  {420, 0, modulation_scheme::QAM64, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input25.dat"}, {"test_data/ldpc_rate_matcher_test_output25.dat"}},
  {924, 2, modulation_scheme::QAM64, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input26.dat"}, {"test_data/ldpc_rate_matcher_test_output26.dat"}},
  {208, 2, modulation_scheme::QAM256, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input27.dat"}, {"test_data/ldpc_rate_matcher_test_output27.dat"}},
  {550, 3, modulation_scheme::QAM1024, 700, false, 28, {"test_data/ldpc_rate_matcher_test_input28.dat"}, {"test_data/ldpc_rate_matcher_test_output28.dat"}},
  {3500, 1, modulation_scheme::QAM1024, 700, true, 0, {"test_data/ldpc_rate_matcher_test_input29.dat"}, {"test_data/ldpc_rate_matcher_test_output29.dat"}},
    // clang-format on
};

} // namespace ocudu
