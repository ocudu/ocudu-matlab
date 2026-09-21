// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "doa_estimator_test_data.h"
#include "ocudu/adt/format.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_configuration.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_factory.h"
#include "fmt/ostream.h"
#include <gtest/gtest.h>

using namespace ocudu;

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(os,
             "n. antennas {}, antenna distance {} wavelengths, cross_polarized {}",
             test_case.doa_config.nof_antennas,
             test_case.doa_config.antenna_distance_over_wavelength,
             test_case.doa_config.cross_polarized);
  return os;
}

} // namespace ocudu

namespace {

class DOAEstimatorFixture : public ::testing::TestWithParam<test_case_t>
{};

TEST_P(DOAEstimatorFixture, DOAEstimatorTest)
{
  const test_case_t&                 test_case = GetParam();
  const doa_estimator_configuration& config    = test_case.doa_config;

  std::shared_ptr<doa_estimator_factory> doa_factory = create_doa_estimator_factory(config);
  ASSERT_TRUE(doa_factory) << "Could not create DOA estimator factory.";

  std::unique_ptr<doa_estimator> doa = doa_factory->create();
  ASSERT_TRUE(doa) << "Could not create DOA estimator.";

  dynamic_tensor<2, cf_t> data = test_case.data.read();
  ASSERT_EQ(data.get_dimension_size(1), config.nof_antennas);

  dynamic_tensor<2, cf_t> srs_sequences = test_case.srs_sequences.read();

  std::optional<doa_estimator_result> doa_results = doa->estimate(data);
  ASSERT_TRUE(doa_results.has_value()) << "Results should not be empty.";

  unsigned nof_angles = test_case.expected_angles.size();

  ASSERT_EQ(test_case.expected_spectrum.size(), nof_angles)
      << fmt::format("The number of expected angles {} and corresponding spectrum values {} should be equal.",
                     test_case.expected_spectrum.size(),
                     nof_angles);
  ASSERT_EQ(doa_results->doa_components.size(), nof_angles)
      << fmt::format("The number of expected angles {} and the number of computed angles {} should be equal.",
                     nof_angles,
                     doa_results->doa_components.size());

  for (unsigned i_angle = 0; i_angle != nof_angles; ++i_angle) {
    const auto& this_angle = doa_results->doa_components[i_angle];
    ASSERT_NEAR(this_angle.broadside_angle_degrees, test_case.expected_angles[i_angle], 0.001)
        << fmt::format("Expected {} and estimated {} angles do not match.",
                       test_case.expected_angles[i_angle],
                       this_angle.broadside_angle_degrees);
    ASSERT_NEAR(this_angle.spectrum_strength,
                test_case.expected_spectrum[i_angle],
                test_case.expected_spectrum[i_angle] / 100.0F)
        << fmt::format("Expected {} and estimated {} spectrums do not match.",
                       test_case.expected_spectrum[i_angle],
                       this_angle.spectrum_strength);
  }
}

INSTANTIATE_TEST_SUITE_P(DOAEstimatorFixture, DOAEstimatorFixture, ::testing::ValuesIn(doa_estimator_test_data));

} // namespace
