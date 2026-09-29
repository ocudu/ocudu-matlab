// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#pragma once

#include "ocudu/adt/tensor.h"
#include "ocudu/ocuduvec/copy.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_configuration.h"
#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_factory.h"
#include "ocudu/ran/resource_block.h"
#include "ocudu/ran/srs/srs_constants.h"
#include "ocudu/ran/srs/srs_properties.h"

namespace ocudu {

class doa_estimator_spy : public doa_estimator
{
public:
  using data_matrix_type = tensor<2, cf_t>;

  /// \brief Maximum sequence length in subcarriers.
  ///
  /// It is given by the maximum value of \f$m_{SRS,0}\f$ in TS38.211 Table 6.4.1.4.3-1 and a comb size of 2.
  static constexpr unsigned max_seq_length = 272 * NOF_SUBCARRIERS_PER_RB / 2;

  /// Constructor: Configures the estimator and reserves internal memory.
  explicit doa_estimator_spy(const doa_estimator_configuration& config_in) : config(config_in), expected_result(1)
  {
    expected_result.doa_components[0].broadside_angle_degrees = 1.0F;
    expected_result.doa_components[0].spectrum_strength       = 1.0F;
  }

  // See the doa_estimator interface for documentation.
  std::optional<doa_estimator_result> estimate(const data_matrix_type& data) override
  {
    data_matrix_type::dimensions_size_type data_size = data.get_dimensions_size();
    ocudu_assert(data_size[1] == config.nof_antennas,
                 "The number of data columns {} should be equal to the configured number of antennas {}.",
                 data_size[1],
                 config.nof_antennas);
    doa_data.resize(data_size);

    ocuduvec::copy(doa_data.get_view<2>({}), data.get_view<2>({}));
    ++nof_calls;
    return expected_result;
  }

  const data_matrix_type&     get_data() const { return doa_data; }
  const doa_estimator_result& get_result() const { return expected_result; }
  unsigned                    get_nof_calls() const { return nof_calls; }

private:
  /// Estimator configuration.
  doa_estimator_configuration config;
  /// Auxiliary buffer for storing data for DOA estimation.
  static_tensor<2, cf_t, max_seq_length* static_cast<unsigned>(srs_nof_symbols::n4) * srs_constants::max_nof_rx_ports>
      doa_data;
  /// Expected result.
  static constexpr unsigned num_results = 1;
  doa_estimator_result      expected_result;
  /// Number of calls of the estimate function.
  unsigned nof_calls = 0;
};

class doa_estimator_spy_factory : public doa_estimator_factory
{
public:
  explicit doa_estimator_spy_factory(const doa_estimator_configuration& config_in) : config(config_in) {}
  std::unique_ptr<doa_estimator> create() override
  {
    std::unique_ptr<doa_estimator_spy> new_spy = std::make_unique<doa_estimator_spy>(config);
    spy                                        = new_spy.get();
    ocudu_assert(spy, "Invalid DOA estimator.");
    return new_spy;
  }

  doa_estimator_spy* spy = nullptr;

private:
  /// Estimator configuration.
  doa_estimator_configuration config;
};
} // namespace ocudu
