/*
 *
 * Copyright 2021-2026 Software Radio Systems Limited
 *
 * By using this file, you agree to the terms and conditions set
 * forth in the LICENSE file which can be found at the top level of
 * the distribution.
 *
 */

#include "channel_equalizer_test_data.h"
#include "compare_sequences.h"
#include "ocudu/adt/expected.h"
#include "ocudu/ocuduvec/copy.h"
#include "ocudu/ocuduvec/zero.h"
#include "ocudu/phy/support/re_buffer.h"
#include "ocudu/phy/upper/equalization/dynamic_ch_est_list.h"
#include "ocudu/phy/upper/equalization/equalization_factories.h"
#include "fmt/ostream.h"
#include <gtest/gtest.h>

using namespace ocudu;

static constexpr float max_abs_eq_symbol_error = 1.0F / 16.0F;
static constexpr float max_abs_eq_nvar_error   = 1.0F / 64.0F;

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(os,
             "{}_{}Tx_{}Rx_{}REs_{}beta_{}nvar",
             test_case.context.equalizer_type,
             test_case.context.nof_layers,
             test_case.context.nof_rx_ports,
             test_case.context.nof_re,
             static_cast<unsigned>(test_case.context.scaling * 1000),
             static_cast<unsigned>(test_case.context.noise_var * 1000));
  return os;
}

std::ostream& operator<<(std::ostream& os, span<const cf_t> data)
{
  fmt::print(os, "{}", data);
  return os;
}

std::ostream& operator<<(std::ostream& os, span<const float> data)
{
  fmt::print(os, "{}", data);
  return os;
}

} // namespace ocudu

static auto compare_eq_symbols = [](cf_t left, cf_t right) {
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

static auto compare_nvars = [](float left, float right) {
  // If one of the inputs is not normal, the two inputs must be exactly the same. Return an error equal to infinity if
  // not to make sure it's bigger than the tolerance.
  if (std::isinf(left) || std::isinf(right) || std::isnan(left) || std::isnan(right)) {
    return (left == right) ? 0.0F : std::numeric_limits<float>::infinity();
  }
  float absolute_error = std::abs(left - right);
  float relative_error = absolute_error / std::abs(left);
  return relative_error;
};

namespace {

using ChannelEqualizerParams = test_case_t;

class ChannelEqualizerFixture : public ::testing::TestWithParam<ChannelEqualizerParams>
{
protected:
  dynamic_re_buffer<cbf16_t> rx_symbols;
  dynamic_ch_est_list        test_ch_estimates;
  std::vector<cf_t>          eq_symbols_expected;
  std::vector<cf_t>          eq_symbols_actual;
  std::vector<float>         eq_noise_vars_expected;

  std::vector<float> eq_noise_vars_actual;

  std::vector<float> test_noise_vars;

  std::shared_ptr<channel_equalizer_factory> equalizer_factory;
  std::unique_ptr<channel_equalizer>         test_equalizer;

  ChannelEqualizerFixture() : TestWithParam<ocudu::test_case_t>(), rx_symbols(4, 1000) {}

  void SetUp() override
  {
    const test_case_t& t_case         = GetParam();
    const std::string& equalizer_type = t_case.context.equalizer_type;

    // Read test case data.
    ReadData(t_case);

    // Create channel equalizer factory.
    channel_equalizer_algorithm_type algorithm_type = channel_equalizer_algorithm_type::zf;
    if (equalizer_type == "MMSE") {
      algorithm_type = channel_equalizer_algorithm_type::mmse;
    }

    equalizer_factory = create_channel_equalizer_generic_factory(algorithm_type);
    ASSERT_NE(equalizer_factory, nullptr) << "Cannot create equalizer factory";

    // Create channel equalizer.
    test_equalizer = equalizer_factory->create();
    ASSERT_NE(test_equalizer, nullptr) << "Cannot create channel equalizer";

    // Verify if the channel equalizer supports the channel topology and algorithm.
    if (!test_equalizer->is_supported(t_case.context.nof_rx_ports, t_case.context.nof_layers)) {
      GTEST_SKIP();
    }
  }

  void ReadData(const ChannelEqualizerParams& t_case)
  {
    unsigned nof_re       = t_case.context.nof_re;
    unsigned nof_rx_ports = t_case.context.nof_rx_ports;
    unsigned nof_layers   = t_case.context.nof_layers;

    // Resize the equalizer input data structures.
    rx_symbols.resize(nof_rx_ports, nof_re);
    test_ch_estimates.resize(nof_re, nof_rx_ports, nof_layers);
    test_noise_vars.resize(nof_rx_ports);

    // Read the test case symbols and estimates.
    const auto rx_symbols_vector = t_case.received_symbols.read();
    for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
      ocuduvec::copy(rx_symbols.get_slice(i_port),
                     span<const cf_t>(rx_symbols_vector).subspan(nof_re * i_port, nof_re));
    }
    ocuduvec::copy(test_ch_estimates.get_data(), t_case.ch_estimates.read());

    // Prepare noise variance per receive port.
    std::fill(test_noise_vars.begin(), test_noise_vars.end(), t_case.context.noise_var);

    // Resize the equalizer output data structures.
    eq_noise_vars_actual.resize(nof_re * nof_layers);
    eq_symbols_actual.resize(nof_re * nof_layers);

    // Read expected equalizer outputs.
    eq_symbols_expected    = t_case.equalized_symbols.read();
    eq_noise_vars_expected = t_case.equalized_noise_vars.read();
  }
};

TEST_P(ChannelEqualizerFixture, ChannelEqualizerTest)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Equalize the symbols coming from the Rx ports.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerAllZeroNvar)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force noise variances set to zero.
  ocuduvec::zero(test_noise_vars);

  // Update expected equalizer outputs.
  std::fill(eq_symbols_expected.begin(), eq_symbols_expected.end(), cf_t());
  std::fill(eq_noise_vars_expected.begin(), eq_noise_vars_expected.end(), std::numeric_limits<float>::infinity());

  // Equalize the symbols coming from the Rx ports using the modified noise variances.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerOneZeroNvar)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force noise variances set to zero.
  test_noise_vars.front() = 0;

  // Equalize the symbols coming from the Rx ports using the modified noise variances.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Skip assertions, the test shall not abort.
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerZeroEst)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force some channel estimates to zero and recalculate their expected output.
  {
    static constexpr unsigned stride       = 5;
    unsigned                  nof_re       = t_case.context.nof_re;
    unsigned                  nof_rx_ports = t_case.context.nof_rx_ports;
    unsigned                  nof_layers   = t_case.context.nof_layers;

    for (unsigned i_layer = 0; i_layer != nof_layers; ++i_layer) {
      for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
        for (unsigned i_re = 0; i_re < nof_re; i_re += stride) {
          test_ch_estimates.get_channel(i_port, i_layer)[i_re] = cf_t();
          eq_symbols_expected[nof_layers * i_re + i_layer]     = cf_t();
          eq_noise_vars_expected[nof_layers * i_re + i_layer]  = std::numeric_limits<float>::infinity();
        }
      }
    }
  }

  // Equalize the symbols coming from the Rx ports with the modified channel estimates.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerInfNvar)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force noise variances set to infinity.
  std::fill(test_noise_vars.begin(), test_noise_vars.end(), std::numeric_limits<float>::infinity());

  // Update expected equalizer outputs.
  std::fill(eq_symbols_expected.begin(), eq_symbols_expected.end(), cf_t());
  std::fill(eq_noise_vars_expected.begin(), eq_noise_vars_expected.end(), std::numeric_limits<float>::infinity());

  // Equalize the symbols coming from the Rx ports using the modified noise variances.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerInfEst)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force some channel estimates to zero and recalculate their expected output.
  {
    static constexpr unsigned stride       = 5;
    unsigned                  nof_re       = t_case.context.nof_re;
    unsigned                  nof_rx_ports = t_case.context.nof_rx_ports;
    unsigned                  nof_layers   = t_case.context.nof_layers;

    for (unsigned i_layer = 0; i_layer != nof_layers; ++i_layer) {
      for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
        for (unsigned i_re = 0; i_re < nof_re; i_re += stride) {
          test_ch_estimates.get_channel(i_port, i_layer)[i_re] = std::numeric_limits<float>::infinity();
          eq_symbols_expected[nof_layers * i_re + i_layer]     = cf_t();
          eq_noise_vars_expected[nof_layers * i_re + i_layer]  = std::numeric_limits<float>::infinity();
        }
      }
    }
  }

  // Equalize the symbols coming from the Rx ports with the modified channel estimates.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerNanNvar)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force noise variances set to NaN.
  std::fill(test_noise_vars.begin(), test_noise_vars.end(), std::numeric_limits<float>::quiet_NaN());

  // Update expected equalizer outputs.
  std::fill(eq_symbols_expected.begin(), eq_symbols_expected.end(), cf_t());
  std::fill(eq_noise_vars_expected.begin(), eq_noise_vars_expected.end(), std::numeric_limits<float>::infinity());

  // Equalize the symbols coming from the Rx ports using the modified noise variances.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerNanEst)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force some channel estimates to zero and recalculate their expected output.
  {
    static constexpr unsigned stride       = 5;
    unsigned                  nof_re       = t_case.context.nof_re;
    unsigned                  nof_rx_ports = t_case.context.nof_rx_ports;
    unsigned                  nof_layers   = t_case.context.nof_layers;

    for (unsigned i_layer = 0; i_layer != nof_layers; ++i_layer) {
      for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
        for (unsigned i_re = 0; i_re < nof_re; i_re += stride) {
          test_ch_estimates.get_channel(i_port, i_layer)[i_re] = std::numeric_limits<float>::quiet_NaN();
          eq_symbols_expected[nof_layers * i_re + i_layer]     = cf_t();
          eq_noise_vars_expected[nof_layers * i_re + i_layer]  = std::numeric_limits<float>::infinity();
        }
      }
    }
  }

  // Equalize the symbols coming from the Rx ports with the modified channel estimates.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

TEST_P(ChannelEqualizerFixture, ChannelEqualizerNegNvar)
{
  // Load the test case data.
  const test_case_t& t_case = GetParam();

  // Force noise variances set to negative values.
  std::fill(test_noise_vars.begin(), test_noise_vars.end(), -1.0F);

  // Update expected equalizer outputs.
  std::fill(eq_symbols_expected.begin(), eq_symbols_expected.end(), cf_t());
  std::fill(eq_noise_vars_expected.begin(), eq_noise_vars_expected.end(), std::numeric_limits<float>::infinity());

  // Equalize the symbols coming from the Rx ports using the modified noise variances.
  test_equalizer->equalize(
      eq_symbols_actual, eq_noise_vars_actual, rx_symbols, test_ch_estimates, test_noise_vars, t_case.context.scaling);

  // Assert results.
  error_type<std::string> eq_symbols_ok = compare_sequences(span<const cf_t>(eq_symbols_actual),
                                                            span<const cf_t>(eq_symbols_expected),
                                                            compare_eq_symbols,
                                                            max_abs_eq_symbol_error);
  ASSERT_TRUE(eq_symbols_ok.has_value()) << eq_symbols_ok.error();

  error_type<std::string> eq_noise_ok = compare_sequences(span<const float>(eq_noise_vars_actual),
                                                          span<const float>(eq_noise_vars_expected),
                                                          compare_nvars,
                                                          max_abs_eq_nvar_error);
  ASSERT_TRUE(eq_noise_ok.has_value()) << eq_noise_ok.error();
}

INSTANTIATE_TEST_SUITE_P(ChannelEqualizerTest,
                         ChannelEqualizerFixture,
                         ::testing::ValuesIn(channel_equalizer_test_data),
                         ::testing::PrintToStringParamName());

} // namespace
