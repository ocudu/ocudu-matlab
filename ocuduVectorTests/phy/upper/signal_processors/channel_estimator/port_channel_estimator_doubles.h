/*
 *
 * Copyright 2021-2026 Software Radio Systems Limited
 *
 * By using this file, you agree to the terms and conditions set
 * forth in the LICENSE file which can be found at the top level of
 * the distribution.
 *
 */

#pragma once

#include "ocudu/phy/upper/signal_processors/channel_estimator/factories.h"
#include "ocudu/phy/upper/signal_processors/channel_estimator/port_channel_estimator.h"

namespace ocudu {

/// \brief Mock port channel estimator.
///
/// This port channel estimator provides a \c port_channel_estimator_results interface that returns values that are
/// injected in advance by the user (no estimation is carried out).
class port_channel_estimator_spy : public port_channel_estimator, private port_channel_estimator_results
{
public:
  /// Quantities typically estimated by the port channel estimator (excluding channel coefficients).
  struct placeholders {
    /// Observed average DM-RS EPRE.
    float epre;
    /// Estimated noise variance (single layer).
    float noise_var;
    /// Estimated SNR (linear scale).
    float snr_linear;
    /// Estimated time alignment in seconds.
    float time_alignment_s;
    /// Estimated CFO (may not be available, depending on the configuration).
    std::optional<float> cfo_Hz;
    /// Observed RSRP.
    static_vector<float, /*max layers=*/4> rsrp;
  };

  // Constructor - creates a reference to an object with the mock estimated quantities.
  port_channel_estimator_spy(const placeholders& dummy) : dummy_values(dummy) {}

  // See the port_channel_estimator interface for documentation.
  const port_channel_estimator_results& compute(const resource_grid_reader& grid,
                                                unsigned                    port,
                                                const dmrs_symbol_list&     pilots,
                                                const configuration&        cfg) override
  {
    // Do nothing, just copy the configuration.
    cfg_local = cfg;
    return *this;
  }

private:
  // See the port_channel_estimator_results interface for documentation.
  void get_symbol_ch_estimate(span<cbf16_t> symbol, unsigned i_symbol, unsigned tx_layer) const override {}

  // See the port_channel_estimator_results interface for documentation.
  void get_symbol_ch_estimate(span<cbf16_t>                              symbol,
                              unsigned                                   i_symbol,
                              unsigned                                   tx_layer,
                              const bounded_bitset<MAX_NOF_SUBCARRIERS>& re_mask) const override
  {
  }

  // See the port_channel_estimator_results interface for documentation.
  float get_epre() const override { return dummy_values.epre; }

  // See the port_channel_estimator_results interface for documentation.
  float get_noise_variance() const override { return dummy_values.noise_var; }

  // See the port_channel_estimator_results interface for documentation.
  float get_snr() const override { return dummy_values.snr_linear; }

  // See the port_channel_estimator_results interface for documentation.
  float get_rsrp(unsigned tx_layer) const override
  {
    ocudu_assert(tx_layer < cfg_local.dmrs_pattern.size(),
                 "Layer index {} is larger than the maximum supported index {}.",
                 tx_layer,
                 cfg_local.dmrs_pattern.size() - 1);
    return dummy_values.rsrp[tx_layer];
  }

  // See the port_channel_estimator_results interface for documentation.
  std::optional<float> get_cfo_Hz() const override { return dummy_values.cfo_Hz; }

  // See the port_channel_estimator_results interface for documentation.
  phy_time_unit get_time_alignment() const override
  {
    return phy_time_unit::from_seconds(dummy_values.time_alignment_s);
  }

  /// Channel estimator configuration.
  configuration cfg_local = {};

  /// Dummy estimated parameters.
  const placeholders& dummy_values;
};

class port_channel_estimator_factory_spy : public port_channel_estimator_factory
{
public:
  port_channel_estimator_factory_spy(span<port_channel_estimator_spy::placeholders> dummy_values_) :
    dummy_values(dummy_values_)
  {
  }

  std::unique_ptr<port_channel_estimator> create(port_channel_estimator_fd_smoothing_strategy /*unused*/,
                                                 port_channel_estimator_td_interpolation_strategy /*unused*/,
                                                 bool /*unused*/) override
  {
    ocudu_assert(counter < dummy_values.size(),
                 "Trying to create {} port_channel_estimator_spy objects, but only {} configured.",
                 dummy_values.size());
    return std::make_unique<port_channel_estimator_spy>(dummy_values[counter++]);
  }

private:
  span<port_channel_estimator_spy::placeholders> dummy_values;
  unsigned                                       counter = 0;
};

inline std::shared_ptr<port_channel_estimator_factory>
create_port_channel_estimator_factory_spy(span<port_channel_estimator_spy::placeholders> dummy_values)
{
  return std::make_shared<port_channel_estimator_factory_spy>(dummy_values);
}

} // namespace ocudu
