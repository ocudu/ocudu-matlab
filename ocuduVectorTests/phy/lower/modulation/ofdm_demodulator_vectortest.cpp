// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "compare_sequences.h"
#include "ofdm_demodulator_test_data.h"
#include "resource_grid_test_doubles.h"
#include "ocudu/ocuduvec/conversion.h"
#include "ocudu/phy/antenna_ports.h"
#include "ocudu/phy/generic_functions/generic_functions_factories.h"
#include "ocudu/phy/lower/modulation/modulation_factories.h"
#include "fmt/ostream.h"
#include <gtest/gtest.h>

namespace ocudu {

static std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(os,
             "numerology={} bw_rb={} dft_size={} cp={} wo={} sf={} cf={:.3f}MHz",
             test_case.test_config.config.numerology,
             test_case.test_config.config.bw_rb,
             test_case.test_config.config.dft_size,
             test_case.test_config.config.cp.to_string(),
             test_case.test_config.config.nof_samples_window_offset,
             test_case.test_config.config.scale,
             test_case.test_config.config.center_freq_Hz / 1e6);
  return os;
}

} // namespace ocudu

using namespace ocudu;

static constexpr float max_abs_symbols_error = 1e-2;

class ofdm_demodulator_tester : public ::testing::TestWithParam<test_case_t>
{
protected:
  std::unique_ptr<ofdm_slot_demodulator> demodulator;

  void SetUp() override
  {
    const test_case_t& test_case = GetParam();

    std::shared_ptr<dft_processor_factory> dft_factory = create_dft_processor_factory_generic();
    ASSERT_TRUE(dft_factory);

    ofdm_factory_generic_configuration factory_config = {.dft_factory = dft_factory};

    std::shared_ptr<ofdm_demodulator_factory> ofdm_factory = create_ofdm_demodulator_factory_generic(factory_config);
    ASSERT_TRUE(ofdm_factory);

    ofdm_factory = create_ofdm_demodulator_pool_factory(std::move(ofdm_factory), 2);
    ASSERT_TRUE(ofdm_factory);

    demodulator = ofdm_factory->create_ofdm_slot_demodulator(test_case.test_config.config);
    ASSERT_TRUE(demodulator);
  }
};

TEST_P(ofdm_demodulator_tester, vector)
{
  const test_case_t& test_case = GetParam();

  resource_grid_writer_spy grid(MAX_PORTS, MAX_NSYMB_PER_SLOT, test_case.test_config.config.bw_rb);

  // Load the input data in floating point.
  std::vector<cf_t> input_cf;
  input_cf = test_case.data.read();

  // Convert input to 16-bit integer.
  std::vector<ci16_t> input_ci16(input_cf.size());
  ocuduvec::convert(input_ci16, input_cf, ocuduvec::scaling_factor_cf_to_ci16);

  // Demodulate signal.
  demodulator->demodulate(grid, input_ci16, test_case.test_config.port_idx, test_case.test_config.slot_idx);

  // Load the golden data and  build grid with the expected demodulated data.
  resource_grid_reader_spy expected_demodulated_grid(MAX_PORTS, MAX_NSYMB_PER_SLOT, test_case.test_config.config.bw_rb);
  expected_demodulated_grid.write(test_case.demodulated.read());

  // Validate each OFDM symbol within the slot.
  for (unsigned i_symbol = 0, nof_symbols = get_nsymb_per_slot(test_case.test_config.config.cp);
       i_symbol != nof_symbols;
       ++i_symbol) {
    error_type<std::string> demod_symbols_ok = compare_sequences(
        grid.get_view(test_case.test_config.port_idx, i_symbol),
        expected_demodulated_grid.get_view(test_case.test_config.port_idx, i_symbol),
        [](const cbf16_t& actual, const cbf16_t& expected) { return std::abs(to_cf(actual) - to_cf(expected)); },
        max_abs_symbols_error);
    ASSERT_TRUE(demod_symbols_ok.has_value()) << demod_symbols_ok.error();
  }
}

INSTANTIATE_TEST_SUITE_P(ofdm_demodulator_vectortest,
                         ofdm_demodulator_tester,
                         ::testing::ValuesIn(ofdm_demodulator_test_data));
