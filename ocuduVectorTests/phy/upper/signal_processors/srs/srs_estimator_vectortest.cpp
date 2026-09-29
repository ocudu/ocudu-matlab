// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "compare_sequences.h"
#include "doa_estimator_test_doubles.h"
#include "resource_grid_test_doubles.h"
#include "srs_estimator_test_data.h"
#include "ocudu/adt/format.h"
#include "ocudu/phy/generic_functions/generic_functions_factories.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_configuration.h"
#include "ocudu/phy/upper/signal_processors/srs/formatters.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator_configuration.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator_factory.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator_result.h"
#include "ocudu/ran/phy_time_unit.h"
#include "ocudu/ran/srs/srs_channel_matrix_formatters.h"
#include "fmt/ostream.h"
#include <gtest/gtest.h>
#include <memory>

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(os, "{}", test_case.context.config);
  return os;
}

std::ostream& operator<<(std::ostream& os, const srs_channel_matrix& channel)
{
  fmt::print(os, "{}", channel);
  return os;
}

bool operator==(const srs_channel_matrix& left, const srs_channel_matrix& right)
{
  return left.is_near(right, 0.05F);
}

} // namespace ocudu

using namespace ocudu;

class srsEstimatorFixture : public ::testing::TestWithParam<test_case_t>
{
protected:
  void SetUp() override
  {
    std::shared_ptr<dft_processor_factory> dft_proc_factory = create_dft_processor_factory_fftw_slow();
    if (!dft_proc_factory) {
      dft_proc_factory = create_dft_processor_factory_generic();
    }
    ASSERT_NE(dft_proc_factory, nullptr);

    std::shared_ptr<time_alignment_estimator_factory> ta_estimator_factory =
        create_time_alignment_estimator_dft_factory(dft_proc_factory);
    ASSERT_NE(ta_estimator_factory, nullptr);

    std::shared_ptr<low_papr_sequence_generator_factory> sequence_generator_factory =
        create_low_papr_sequence_generator_sw_factory();
    ASSERT_NE(sequence_generator_factory, nullptr);

    const test_case_t&          test_case    = GetParam();
    unsigned                    nof_antennas = test_case.context.config.ports.size();
    doa_estimator_configuration doa_config   = {
        .nof_antennas                     = nof_antennas,
        .antenna_distance_over_wavelength = 0.2F,  // unused
        .cross_polarized                  = false, // unused
    };
    std::shared_ptr<doa_estimator_spy_factory> doa_factory = std::make_shared<doa_estimator_spy_factory>(doa_config);
    ASSERT_NE(doa_factory, nullptr);

    std::shared_ptr<srs_estimator_factory> srs_est_factory = create_srs_estimator_generic_factory(
        sequence_generator_factory, ta_estimator_factory, doa_factory, MAX_NOF_PRBS);
    ASSERT_NE(srs_est_factory, nullptr);

    estimator = srs_est_factory->create();
    ASSERT_NE(estimator, nullptr);
    doa_spy = doa_factory->spy;
    ASSERT_NE(doa_spy, nullptr);

    validator = srs_est_factory->create_validator();
    ASSERT_NE(validator, nullptr);
  }

  std::unique_ptr<srs_estimator>                         estimator = nullptr;
  std::unique_ptr<srs_estimator_configuration_validator> validator = nullptr;
  doa_estimator_spy*                                     doa_spy   = nullptr;
};

TEST_P(srsEstimatorFixture, FromVector)
{
  const test_case_t&                 test_case = GetParam();
  const srs_estimator_configuration& config    = test_case.context.config;

  resource_grid_reader_spy grid;
  grid.write(GetParam().rx_grid.read());

  ASSERT_TRUE(validator->is_valid(config));

  srs_estimator_result result = estimator->estimate(grid, config);

  ASSERT_EQ(test_case.context.result.channel_matrix.normalize(), result.channel_matrix.normalize());
  ASSERT_TRUE(result.epre_dB.has_value());
  ASSERT_NEAR(
      convert_dB_to_power(test_case.context.result.epre_dB.value()), convert_dB_to_power(result.epre_dB.value()), 5e-3);

  double ta_aligment_tolerance_s =
      ocudu::phy_time_unit::from_timing_advance(1, to_subcarrier_spacing(config.slot.numerology())).to_seconds();
  ASSERT_NEAR(test_case.context.result.time_alignment.time_alignment,
              result.time_alignment.time_alignment,
              ta_aligment_tolerance_s);

  // Check DOA: here we only check that the DOA estimator is integrated correctly. For the DOA algorithm, see
  // doa_estimator_vectortest.cpp. DOA estimator should have been called only once.
  ASSERT_EQ(doa_spy->get_nof_calls(), 1);
  // SRS result should carry a DOA result.
  ASSERT_TRUE(result.doa_result.has_value());
  doa_estimator_result        actual_doa   = *result.doa_result;
  const doa_estimator_result& expected_doa = doa_spy->get_result();
  unsigned                    nof_results  = expected_doa.doa_components.size();
  ASSERT_EQ(actual_doa.doa_components.size(), nof_results);
  for (unsigned i_result = 0; i_result != nof_results; ++i_result) {
    ASSERT_EQ(actual_doa.doa_components[i_result].broadside_angle_degrees,
              expected_doa.doa_components[i_result].broadside_angle_degrees);
    ASSERT_EQ(actual_doa.doa_components[i_result].spectrum_strength,
              expected_doa.doa_components[i_result].spectrum_strength);
  }

  const tensor<2, cf_t>&                doa_data     = doa_spy->get_data();
  tensor<2, cf_t>::dimensions_size_type data_size    = doa_data.get_dimensions_size();
  unsigned                              nof_rx_ports = config.ports.size();
  ASSERT_EQ(data_size[1], nof_rx_ports);

  // Now check the right data was passed to the DOA estimator: all REs (for all symbols and Rx antenna ports)
  // corresponding to the SRS signal sent from Tx antenna port 0.
  srs_information                                        info            = get_srs_information(config.resource, 0);
  unsigned                                               sequence_length = info.sequence_length;
  static_vector<cf_t, doa_estimator_spy::max_seq_length> rx_sequence(sequence_length);
  for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
    span<const cf_t> actual_data = doa_data.get_view({i_port});
    for (unsigned i_symbol     = config.resource.start_symbol.value(),
                  i_symbol_end = config.resource.start_symbol.value() + config.resource.nof_symbols;
         i_symbol != i_symbol_end;
         ++i_symbol) {
      // Extract received sequence.
      grid.get(rx_sequence, i_port, i_symbol, info.mapping_initial_subcarrier, info.comb_size);
      error_type<std::string> data_ok = compare_sequences(
          span<const cf_t>(rx_sequence),
          actual_data.first(sequence_length),
          [](cf_t a, cf_t b) { return std::norm(a - b); },
          0.0F);
      actual_data = actual_data.last(actual_data.size() - sequence_length);
      ASSERT_TRUE(data_ok.has_value()) << data_ok.error();
    }
    ASSERT_EQ(actual_data.size(), 0);
  }
}

INSTANTIATE_TEST_SUITE_P(srsEstimatorFixture, srsEstimatorFixture, ::testing::ValuesIn(srs_estimator_test_data));
