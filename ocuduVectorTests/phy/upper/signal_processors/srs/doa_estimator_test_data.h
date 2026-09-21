// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#pragma once

// This file was generated using the following MATLAB class on 28-09-2026 (seed 0):
//   + "ocuduSRSDOAEstimatorUnittest.m"

#include "ocudu/adt/complex.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_configuration.h"
#include "ocudu/support/file_tensor.h"
#include <vector>

namespace ocudu {

struct test_case_t {
  doa_estimator_configuration doa_config;
  std::vector<float>          expected_angles;
  std::vector<float>          expected_spectrum;
  file_tensor<2, cf_t>        data;
  file_tensor<2, cf_t>        srs_sequences;
};

static const std::vector<test_case_t> doa_estimator_test_data = {
    // clang-format off
  {{4, 0.5005, false}, {{72, -70}}, {{3131.074, 1840.782}}, {"test_data/doa_estimator_test_input_data0.dat", {3168, 4}}, {"test_data/doa_estimator_test_srs0.dat", {3168, 1}}},
  {{4, 0.5005, true}, {-35}, {9893.3828}, {"test_data/doa_estimator_test_input_data1.dat", {3168, 4}}, {"test_data/doa_estimator_test_srs1.dat", {3168, 1}}},
  {{8, 0.5005, false}, {{6, -4, -60}}, {{15.946,  3.986, 1.717}}, {"test_data/doa_estimator_test_input_data2.dat", {3168, 8}}, {"test_data/doa_estimator_test_srs2.dat", {3168, 1}}},
  {{8, 0.5005, true}, {{35, -30}}, {{309.101, 172.944}}, {"test_data/doa_estimator_test_input_data3.dat", {3168, 8}}, {"test_data/doa_estimator_test_srs3.dat", {3168, 1}}},
  {{16, 0.5005, false}, {25}, {132.3663}, {"test_data/doa_estimator_test_input_data4.dat", {3168, 16}}, {"test_data/doa_estimator_test_srs4.dat", {3168, 1}}},
  {{16, 0.5005, true}, {{-74,  36, -44,  10, -11}}, {{19.500, 17.624,  5.917,  0.534, 0.500}}, {"test_data/doa_estimator_test_input_data5.dat", {3168, 16}}, {"test_data/doa_estimator_test_srs5.dat", {3168, 1}}},
    // clang-format on
};

} // namespace ocudu
