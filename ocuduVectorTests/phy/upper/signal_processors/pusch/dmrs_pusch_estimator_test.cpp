// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "../channel_estimator/port_channel_estimator_doubles.h"
#include "dmrs_pusch_estimator_test_data.h"
#include "resource_grid_test_doubles.h"
#include "ocudu/ocuduvec/zero.h"
#include "ocudu/phy/antenna_ports.h"
#include "ocudu/phy/upper/channel_estimation.h"
#include "ocudu/phy/upper/signal_processors/pusch/factories.h"
#include "ocudu/support/executors/inline_task_executor.h"
#include "fmt/ostream.h"
#include "gtest/gtest.h"

using namespace ocudu;

namespace ocudu {

std::ostream& operator<<(std::ostream& os, dmrs_pusch_estimator::configuration config)
{
  fmt::print(os,
             "slot={}; type={}; scaling={:.3f}; cp={}; dmrs_pos={}; f_alloc={:x}; "
             "t_alloc={}:{}; tx_layers={}; rx_ports=[{}];",
             config.slot,
             config.get_dmrs_type() == dmrs_type::TYPE1 ? "1" : "2",
             config.scaling,
             config.c_prefix.to_string(),
             config.symbols_mask,
             config.rb_mask,
             config.first_symbol,
             config.nof_symbols,
             config.get_nof_tx_layers(),
             span<const uint8_t>(config.rx_ports));
  return os;
}

std::ostream& operator<<(std::ostream& os, test_case_t test_case)
{
  fmt::print(os, "config={} symbols={};", test_case.config, test_case.rx_symbols.get_file_name());
  return os;
}

} // namespace ocudu

template <>
struct fmt::formatter<ocudu::dmrs_pusch_estimator::configuration> : ostream_formatter {};

namespace {

class dmrs_pusch_estimator_notifier_spy : public dmrs_pusch_estimator_notifier
{
public:
  void on_estimation_complete(const dmrs_pusch_estimator_results& est_results) override
  {
    ++estimation_notified;
    results_ptr = &est_results;
  }

  bool has_notified() const { return (estimation_notified == 1); }

  const dmrs_pusch_estimator_results& get_results() const { return *results_ptr; }

private:
  unsigned                            estimation_notified = 0;
  const dmrs_pusch_estimator_results* results_ptr         = nullptr;
};

class DmrsPuschEstimatorFixture : public ::testing::TestWithParam<test_case_t>
{
protected:
  std::shared_ptr<dmrs_pusch_estimator_factory>         estimator_factory;
  std::shared_ptr<dmrs_pusch_estimator_factory>         estimator_interface_factory;
  resource_grid_reader_spy                              grid;
  inline_task_executor                                  ch_est_executor;
  std::vector<port_channel_estimator_spy::placeholders> dummy_values;

  // Default constructor - initializes the resource grid with the maximum size possible.
  DmrsPuschEstimatorFixture() : ::testing::TestWithParam<ParamType>(), grid(MAX_PORTS, MAX_NSYMB_PER_SLOT, MAX_NOF_PRBS)
  {
  }

  void SetUp() override
  {
    const test_case_t& test_case = GetParam();

    // Create PRG.
    std::shared_ptr<pseudo_random_generator_factory> prg_factory = create_pseudo_random_generator_sw_factory();
    ASSERT_TRUE(prg_factory);

    // Create low-PAPR sequence generator.
    std::shared_ptr<low_papr_sequence_generator_factory> low_papr_sequence_gen_factory_factory =
        create_low_papr_sequence_generator_sw_factory();
    ASSERT_TRUE(low_papr_sequence_gen_factory_factory);

    std::shared_ptr<dft_processor_factory> dft_factory = create_dft_processor_factory_fftw_slow();
    if (!dft_factory) {
      dft_factory = create_dft_processor_factory_generic();
    }
    ASSERT_NE(dft_factory, nullptr) << "Cannot create DFT factory.";

    std::shared_ptr<time_alignment_estimator_factory> ta_estimator_factory =
        create_time_alignment_estimator_dft_factory(dft_factory);
    ASSERT_NE(ta_estimator_factory, nullptr) << "Cannot create TA estimator factory.";

    // Create factory for full port estimators.
    std::shared_ptr<port_channel_estimator_factory> port_estimator_factory =
        create_port_channel_estimator_factory_sw(ta_estimator_factory);
    ASSERT_TRUE(port_estimator_factory);

    // Create estimator factory with full port channel estimator.
    estimator_factory =
        create_dmrs_pusch_estimator_factory_sw(prg_factory,
                                               low_papr_sequence_gen_factory_factory,
                                               port_estimator_factory,
                                               ch_est_executor,
                                               test_case.config.rx_ports.size(),
                                               port_channel_estimator_fd_smoothing_strategy::filter,
                                               port_channel_estimator_td_interpolation_strategy::average,
                                               true);
    ASSERT_TRUE(estimator_factory);

    // Create factory for spy port estimators.
    dummy_values.resize(test_case.config.rx_ports.size());
    std::shared_ptr<port_channel_estimator_factory> port_estimator_spy_factory =
        create_port_channel_estimator_factory_spy(dummy_values);
    ASSERT_TRUE(port_estimator_spy_factory);

    estimator_interface_factory =
        create_dmrs_pusch_estimator_factory_sw(prg_factory,
                                               low_papr_sequence_gen_factory_factory,
                                               port_estimator_spy_factory,
                                               ch_est_executor,
                                               test_case.config.rx_ports.size(),
                                               port_channel_estimator_fd_smoothing_strategy::filter,
                                               port_channel_estimator_td_interpolation_strategy::average,
                                               true);
    ASSERT_TRUE(estimator_interface_factory);

    // Setup resource grid symbols.
    std::vector<resource_grid_reader_spy::expected_entry_t> rg_entries = test_case.rx_symbols.read();
    grid.write(rg_entries);
  }
};

} // namespace

static constexpr float tolerance = 0.01;

TEST_P(DmrsPuschEstimatorFixture, Creation)
{
  // Create actual channel estimator.
  std::unique_ptr<dmrs_pusch_estimator> estimator = estimator_factory->create();
  ASSERT_TRUE(estimator);

  // This test only looks at whether the estimator places the DM-RS pilots in the correct position. To this end, the
  // received channel samples have been generated assuming that layers are transmitted on orthogonal channels (one layer
  // - one port), with no impairments. Then, the estimated channel should be one at the pilot coordinates and zero
  // elsewhere.

  dmrs_pusch_estimator::configuration config = GetParam().config;

  // The current estimator does not support Type2 DM-RS.
  if (config.get_dmrs_type() == dmrs_type::TYPE2) {
    GTEST_SKIP() << "Configuration not supported yet, skipping.";
  }

  ASSERT_EQ(config.rx_ports.size(), config.get_nof_tx_layers())
      << "This simulation assumes an equal number of Rx ports and Tx layers.";

  // Prepare channel estimate (just to be sure, reset all entries).
  channel_estimate::channel_estimate_dimensions ch_estimate_dims;
  ch_estimate_dims.nof_prb       = config.rb_mask.size();
  ch_estimate_dims.nof_symbols   = config.nof_symbols + config.first_symbol;
  ch_estimate_dims.nof_rx_ports  = config.rx_ports.size();
  ch_estimate_dims.nof_tx_layers = config.get_nof_tx_layers();

  channel_estimate ch_est(ch_estimate_dims);

  for (unsigned i_port = 0; i_port != ch_estimate_dims.nof_rx_ports; ++i_port) {
    for (unsigned i_layer = 0; i_layer != ch_estimate_dims.nof_tx_layers; ++i_layer) {
      span<cbf16_t> path = ch_est.get_path_ch_estimate(i_port, i_layer);
      ocuduvec::zero(path);
    }
  }

  // Create a spy notifier.
  dmrs_pusch_estimator_notifier_spy notifier;

  // Estimate.
  estimator->estimate(notifier, grid, config);

  // Next, assert the notifier has been called.
  ASSERT_TRUE(notifier.has_notified()) << "The estimator notifier was not called.";
  const dmrs_pusch_estimator_results& results = notifier.get_results();

  unsigned             first_re      = config.rb_mask.find_lowest() * NOF_SUBCARRIERS_PER_RB;
  unsigned             nof_re        = config.rb_mask.size() * NOF_SUBCARRIERS_PER_RB;
  unsigned             nof_re_active = config.rb_mask.count() * NOF_SUBCARRIERS_PER_RB;
  std::vector<cbf16_t> symbol_est(nof_re, {0, 0});
  for (unsigned i_port = 0; i_port != ch_estimate_dims.nof_rx_ports; ++i_port) {
    for (unsigned i_layer = 0; i_layer != ch_estimate_dims.nof_tx_layers; ++i_layer) {
      for (unsigned i_symbol = config.first_symbol; i_symbol != ch_estimate_dims.nof_symbols; ++i_symbol) {
        span<cbf16_t> estimate_values = span<cbf16_t>(symbol_est).subspan(first_re, nof_re_active);
        // Get the channel estimates for the current OFDM symbol.
        results.get_symbol_ch_estimate(estimate_values, i_symbol, i_port, i_layer);

        if (i_port != i_layer) {
          ASSERT_TRUE(std::all_of(symbol_est.begin(), symbol_est.end(), [](cbf16_t a) {
            return (a.real.value() == 0) && (a.imag.value() == 0);
          })) << "REs should be zero on cross paths.";

          continue;
        }

        // Check the retrieved symbol.
        cf_t                value = cf_t(1, 0);
        bool                is_ok = true;
        span<const cbf16_t> symbol_span(symbol_est);
        auto                check_symbol = [&symbol_span, &value, &is_ok](unsigned i_prb) {
          unsigned            i_re = i_prb * NOF_SUBCARRIERS_PER_RB;
          span<const cbf16_t> current_prb = span<const cbf16_t>(symbol_span).subspan(i_re, NOF_SUBCARRIERS_PER_RB);
          is_ok = is_ok && std::all_of(current_prb.begin(), current_prb.end(), [value](cbf16_t a) {
                    return (std::abs(to_cf(a) - value) < tolerance);
                  });
        };
        config.rb_mask.for_each(0, config.rb_mask.size(), check_symbol);
        ASSERT_TRUE(is_ok) << "All estimates in allocated REs should be 1.";

        value = cf_t(0, 0);
        is_ok = true;
        config.rb_mask.for_each(0, config.rb_mask.size(), check_symbol, false);
        ASSERT_TRUE(is_ok) << "All estimates in non-allocated REs should be 0.";

        // Get the channel estimates for the current OFDM symbol according to a mask.
        re_prb_mask active_re_per_prb_dmrs = config.get_dmrs_type().get_dmrs_prb_mask(2);
        crb_bitmap  rb_mask_useful =
            config.rb_mask.slice(config.rb_mask.find_lowest(), config.rb_mask.find_highest() + 1);
        bounded_bitset<MAX_NOF_SUBCARRIERS> re_mask_dmrs =
            rb_mask_useful.kronecker_product<NOF_SUBCARRIERS_PER_RB>(active_re_per_prb_dmrs);

        static_vector<cbf16_t, MAX_NOF_SUBCARRIERS> estimate_values_mask(re_mask_dmrs.count());
        results.get_symbol_ch_estimate(estimate_values_mask, i_symbol, i_port, i_layer, re_mask_dmrs);

        // Check the masked retrieve symbol.
        value                             = cf_t(1, 0);
        is_ok                             = true;
        span<cbf16_t> span_mask           = estimate_values_mask;
        auto          check_masked_symbol = [&span_mask, &estimate_values, &is_ok](unsigned i_re) {
          is_ok     = is_ok && (std::abs(to_cf(span_mask.front()) - to_cf(estimate_values[i_re])) < tolerance);
          span_mask = span_mask.last(span_mask.size() - 1);
        };
        re_mask_dmrs.for_each(0, re_mask_dmrs.size(), check_masked_symbol);
        ASSERT_TRUE(span_mask.empty()) << "Not all estimates in the masked case have been checked.";
        ASSERT_TRUE(is_ok) << "Not all masked estimates are correct.";
      }
    }
  }
}

// Creates random values for the dummy port channel estimators.
static void fill_dummy_values(span<port_channel_estimator_spy::placeholders> dummy_values, unsigned nof_layers)
{
  // Exponential distribution for positive values, uniform (-1, 1) distibution for the rest.
  std::mt19937                          rgen(0);
  std::exponential_distribution<float>  exp(1.0);
  std::uniform_real_distribution<float> uniform(-10.0, 10.0);

  bool set_cfo = (uniform(rgen) > 0);
  for (auto& dv : dummy_values) {
    dv.rsrp.resize(nof_layers);
    for (auto& rsrp : dv.rsrp) {
      rsrp = exp(rgen);
    }
    dv.epre             = exp(rgen);
    dv.noise_var        = exp(rgen);
    dv.snr_linear       = exp(rgen);
    dv.time_alignment_s = uniform(rgen);
    dv.cfo_Hz.reset();
    if (set_cfo) {
      dv.cfo_Hz = uniform(rgen);
    }
  }
}

// Creates a CSI report from the values in the dummy port channel estiamtors.
static channel_state_information expected_csi(span<const port_channel_estimator_spy::placeholders> dummy_values)
{
  float                epre          = 0.0F;
  float                rsrp          = 0;
  float                noise         = 0.0F;
  float                best_path_snr = -std::numeric_limits<float>::infinity();
  float                best_ta       = 0.0F;
  std::optional<float> best_cfo      = std::nullopt;
  std::vector<float>   rsrp_l0;

  for (const auto& dv : dummy_values) {
    epre += dv.epre;
    noise += dv.noise_var;

    float rsrp_help = dv.rsrp[0];
    rsrp += rsrp_help;
    rsrp_l0.push_back(rsrp_help);

    float snr_help = dv.snr_linear;
    if (snr_help > best_path_snr) {
      best_path_snr = snr_help;
      best_ta       = dv.time_alignment_s;
      best_cfo      = dv.cfo_Hz;
    }
  }

  channel_state_information csi;
  epre /= static_cast<float>(dummy_values.size());
  csi.set_epre(convert_power_to_dB(epre));

  csi.set_time_alignment(phy_time_unit::from_seconds(best_ta));

  if (best_cfo.has_value()) {
    csi.set_cfo(*best_cfo);
  }

  csi.set_rsrp_lin(rsrp_l0);

  float snr = rsrp / noise;
  csi.set_sinr_dB(channel_state_information::sinr_type::channel_estimator, convert_power_to_dB(snr));
  return csi;
}

TEST_P(DmrsPuschEstimatorFixture, Interface)
{
  // This test verifies the results interface of the dmrs_pusch_estimator. The port channel estimators are replaced with
  // dummy versions that return preset values for all estimated metrics. The test checks whether the values retrieved
  // through the dmrs_pusch_estimator_results interface are compatible with the values in the dummy port channel
  // estimators. The getter methods get_symbol_ch_estimate and get_path_ch_estimate are testsd in the previous test.

  // Create actual channel estimator.
  std::unique_ptr<dmrs_pusch_estimator> estimator = estimator_interface_factory->create();
  ASSERT_TRUE(estimator);

  dmrs_pusch_estimator::configuration config = GetParam().config;

  unsigned nof_layers = config.get_nof_tx_layers();
  fill_dummy_values(dummy_values, nof_layers);

  // Run the estimator - it won't do anything except creating the interface.
  dmrs_pusch_estimator_notifier_spy notifier;
  estimator->estimate(notifier, grid, config);

  // Assert the notifier has been called.
  ASSERT_TRUE(notifier.has_notified()) << "The estimator notifier was not called.";
  const dmrs_pusch_estimator_results& results = notifier.get_results();

  unsigned nof_ports = config.rx_ports.size();
  for (unsigned i_port = 0; i_port != nof_ports; ++i_port) {
    // Check RSRP per layer and port.
    for (unsigned i_layer = 0; i_layer != nof_layers; ++i_layer) {
      float       rsrp = dummy_values[i_port].rsrp[i_layer];
      std::string msg  = fmt::format("RSRP mismatch for port {}, layer {}.", i_port, i_layer);
      ASSERT_EQ(results.get_rsrp(i_port, i_layer), rsrp) << msg;
      ASSERT_EQ(results.get_rsrp_dB(i_port, i_layer), convert_power_to_dB(rsrp)) << msg;
    }

    // Check noise variance.
    std::string msg = fmt::format("Noise variance mismatch for port {}.", i_port);
    ASSERT_EQ(results.get_noise_variance(i_port), dummy_values[i_port].noise_var) << msg;
    ASSERT_EQ(results.get_noise_variance_dB(i_port), convert_power_to_dB(dummy_values[i_port].noise_var)) << msg;

    // Check EPRE.
    msg = fmt::format("EPRE mismatch for port {}.", i_port);
    ASSERT_EQ(results.get_epre(i_port), dummy_values[i_port].epre) << msg;
    ASSERT_EQ(results.get_epre_dB(i_port), convert_power_to_dB(dummy_values[i_port].epre)) << msg;

    // Check SNR.
    msg = fmt::format("SNR mismatch for port {}.", i_port);
    ASSERT_EQ(results.get_snr(i_port), dummy_values[i_port].snr_linear) << msg;
    ASSERT_EQ(results.get_snr_dB(i_port), convert_power_to_dB(dummy_values[i_port].snr_linear)) << msg;

    // Check time alignment.
    msg      = fmt::format("Time alignment mismatch for port {}.", i_port);
    float ta = dummy_values[i_port].time_alignment_s;
    ASSERT_EQ(results.get_time_alignment(i_port), phy_time_unit::from_seconds(ta)) << msg;

    // Check CFO.
    msg = fmt::format("CFO mismatch for port {}.", i_port);
    ASSERT_EQ(results.get_cfo_Hz(i_port), dummy_values[i_port].cfo_Hz) << msg;
  }

  // Check layer-specific values: RSRP and average SNR.
  for (unsigned i_layer = 0; i_layer != nof_layers; ++i_layer) {
    static_vector<float, MAX_PORTS> rsrp_layer = results.get_rsrp_all_ports(i_layer);
    ASSERT_EQ(rsrp_layer.size(), nof_ports) << "rsrp_layer size does not match the number of configured ports.";

    float all_rsrp  = 0;
    float all_noise = 0;
    for (unsigned i_port = 0; i_port != nof_ports; ++i_port) {
      float       rsrp = dummy_values[i_port].rsrp[i_layer];
      std::string msg  = fmt::format("RSRP mismatch for port {}, layer {}.", i_port, i_layer);
      ASSERT_EQ(rsrp_layer[i_port], rsrp) << msg;

      all_rsrp += dummy_values[i_port].rsrp[i_layer];
      all_noise += dummy_values[i_port].noise_var;
    }

    std::string msg = fmt::format("Average SNR mismatch for, layer {}.", i_layer);
    ASSERT_EQ(results.get_layer_average_snr(i_layer), all_rsrp / all_noise) << msg;
  }

  // Check CSI.
  channel_state_information csi_exp = expected_csi(dummy_values);
  channel_state_information csi;
  results.get_channel_state_information(csi);

  ASSERT_EQ(csi.get_epre_dB(), csi_exp.get_epre_dB()) << "CSI EPRE mismatch.";
  ASSERT_EQ(csi.get_port_rsrp_dB(), csi_exp.get_port_rsrp_dB()) << "CSI RSRP mismatch.";
  ASSERT_EQ(csi.get_sinr_dB(), csi_exp.get_sinr_dB()) << "CSI SNR mismatch.";
  ASSERT_EQ(csi.get_time_alignment(), csi_exp.get_time_alignment()) << "CSI TA mismatch.";
  ASSERT_EQ(csi.get_cfo_Hz(), csi_exp.get_cfo_Hz()) << "CSI CFO mismatch.";
}

// Creates test suite with all the test cases.
INSTANTIATE_TEST_SUITE_P(DmrsPuschEstimatorTest,
                         DmrsPuschEstimatorFixture,
                         ::testing::ValuesIn(dmrs_pusch_estimator_test_data));
