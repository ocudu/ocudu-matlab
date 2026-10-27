// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "compare_sequences.h"
#include "ofdm_prach_demodulator_test_data.h"
#include "prach_buffer_test_doubles.h"
#include "ocudu/ocuduvec/compare.h"
#include "ocudu/ocuduvec/conversion.h"
#include "ocudu/phy/lower/modulation/modulation_factories.h"
#include "ocudu/phy/support/support_factories.h"
#include "ocudu/ran/prach/prach_preamble_information.h"
#include "fmt/ostream.h"
#include <gtest/gtest.h>

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const ofdm_prach_demodulator::configuration& config)
{
  fmt::print(os,
             "slot={}; Format={}; nof_td_occasions={}; nof_fd_occasions={}; "
             "start_symbol={}; rb_offset={}; "
             "nof_prb_ul_grid={}; pusch_scs={};",
             config.slot,
             to_string(config.format),
             config.nof_td_occasions,
             config.nof_fd_occasions,
             config.start_symbol,
             config.rb_offset,
             config.nof_prb_ul_grid,
             to_string(to_subcarrier_spacing(config.slot.numerology())));
  return os;
}

std::ostream& operator<<(std::ostream& os, test_case_t test_case)
{
  fmt::print(os, "srate={}; {}", test_case.context.srate, test_case.context.config);
  return os;
}

} // namespace ocudu

static constexpr float max_abs_symbols_error = 1e-2;

template <>
struct fmt::formatter<ocudu::ofdm_prach_demodulator::configuration> : ostream_formatter {};

using namespace ocudu;

static auto compare_symbols = [](cbf16_t left_cbf, cbf16_t right_cbf) {
  cf_t left  = to_cf(left_cbf);
  cf_t right = to_cf(right_cbf);

  // If one of the inputs is not normal, the two inputs must be exactly the same. Return an error equal to infinity if
  // not to make sure it's bigger than the tolerance.
  if (!std::isnormal(left.real()) || !std::isnormal(left.imag()) || !std::isnormal(right.real()) ||
      !std::isnormal(right.imag())) {
    return (left == right) ? 0.0F : std::numeric_limits<float>::infinity();
  }
  float absolute_error = std::abs(left - right);
  float relative_error = absolute_error / std::abs(left);
  return relative_error;
};

class ofdm_prach_demodulator_tester : public ::testing::TestWithParam<test_case_t>
{
protected:
  std::unique_ptr<ofdm_prach_demodulator> demodulator;

  void SetUp() override
  {
    sampling_rate      srate     = GetParam().context.srate;
    subcarrier_spacing pusch_scs = to_subcarrier_spacing(GetParam().context.config.slot.numerology());

    frequency_range fr = frequency_range::FR1;
    if (pusch_scs > subcarrier_spacing::kHz60) {
      fr = frequency_range::FR2;
    }

    std::shared_ptr<dft_processor_factory> dft_factory = create_dft_processor_factory_generic();
    ASSERT_TRUE(dft_factory);

    std::shared_ptr<ofdm_prach_demodulator_factory> ofdm_factory =
        create_ofdm_prach_demodulator_factory_sw(dft_factory, srate, fr);
    ASSERT_TRUE(ofdm_factory);

    demodulator = ofdm_factory->create();
    ASSERT_TRUE(demodulator);
  }
};

TEST_P(ofdm_prach_demodulator_tester, vector)
{
  const test_case_t&                           test_case = GetParam();
  const ofdm_prach_demodulator::configuration& config    = test_case.context.config;
  subcarrier_spacing pusch_scs = to_subcarrier_spacing(GetParam().context.config.slot.numerology());

  bool long_preamble = is_long_preamble(config.format);
  auto prach_buffer_pool =
      create_spy_prach_buffer_pool(long_preamble, config.nof_fd_occasions, config.nof_td_occasions);

  // Read input waveform in single precision.
  std::vector<cf_t> input_cf = test_case.input.read();

  // Calculate maximum absolute value for correcting the input amplitude.
  unsigned abs_max_pos;
  float    abs_max_value;
  std::tie(abs_max_pos, abs_max_value) = ocuduvec::max_abs_element(input_cf);

  // Convert input to 16-bit integer.
  std::vector<ci16_t> input_ci16(input_cf.size());
  ocuduvec::convert(input_ci16, input_cf, ocuduvec::scaling_factor_cf_to_ci16 / abs_max_value);

  // Read raw expected output and correct the scaling.
  std::vector<cf_t> expected_output = test_case.output.read();
  ocuduvec::sc_prod(expected_output, expected_output, 1 / abs_max_value);

  // Select preamble information.
  prach_preamble_information preamble_info =
      long_preamble ? get_prach_preamble_long_info(config.format)
                    : get_prach_preamble_short_info(config.format, to_ra_subcarrier_spacing(pusch_scs), false);

  // Calculate number of symbols.
  unsigned nof_symbols = preamble_info.nof_symbols;

  // Build expected buffer data.
  prach_buffer_spy expected_buffer(
      expected_output, config.nof_td_occasions, config.nof_fd_occasions, nof_symbols, preamble_info.sequence_length);

  // Run demodulator.
  auto buffer = prach_buffer_pool->get();
  demodulator->demodulate(*buffer, input_ci16, GetParam().context.config);

  // Validate the demodulated sequence matches with the expected for each port, time-domain occasion, frequency-domain
  // occasion and symbol.
  for (unsigned i_port = 0; i_port != 1; ++i_port) {
    for (unsigned i_td_occasion = 0; i_td_occasion != config.nof_td_occasions; ++i_td_occasion) {
      for (unsigned i_fd_occasion = 0; i_fd_occasion != config.nof_fd_occasions; ++i_fd_occasion) {
        for (unsigned i_symbol = 0; i_symbol != nof_symbols; ++i_symbol) {
          error_type<std::string> demod_symbols_ok =
              compare_sequences(buffer->get_symbol(i_port, i_td_occasion, i_fd_occasion, i_symbol),
                                expected_buffer.get_symbol(i_port, i_td_occasion, i_fd_occasion, i_symbol),
                                compare_symbols,
                                max_abs_symbols_error);
          ASSERT_TRUE(demod_symbols_ok.has_value()) << fmt::format("i_port={}; i_td_occasion={}; i_fd_occasion={}; "
                                                                   "i_symbol={}; ",
                                                                   i_port,
                                                                   i_td_occasion,
                                                                   i_fd_occasion,
                                                                   i_symbol)
                                                    << demod_symbols_ok.error();
        }
      }
    }
  }
}

// Creates test suite that combines all possible parameters. Denote
// zero_correlation_zone exceeds the maximum by one.
INSTANTIATE_TEST_SUITE_P(ofdm_prach_demodulator_vectortest,
                         ofdm_prach_demodulator_tester,
                         ::testing::ValuesIn(ofdm_prach_demodulator_test_data));
