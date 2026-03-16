// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI
// Portions of this file may implement 3GPP specifications, which may be subject
// to additional licensing requirements.

#include "pusch_demodulator_mex.h"
#include "ocudu_matlab/support/matlab_to_ocudu.h"
#include "ocudu_matlab/support/resource_grid.h"
#include "ocudu_matlab/support/to_span.h"
#include "ocudu/phy/upper/channel_estimation.h"
#include "ocudu/phy/upper/channel_processors/pusch/pusch_codeword_buffer.h"
#include "ocudu/phy/upper/channel_processors/pusch/pusch_demodulator_notifier.h"
#include <optional>

using matlab::mex::ArgumentList;
using namespace matlab::data;
using namespace ocudu;
using namespace ocudu_matlab;

namespace {

class pusch_codeword_buffer_spy : private pusch_codeword_buffer
{
public:
  explicit pusch_codeword_buffer_spy(span<log_likelihood_ratio> data_) : data(data_) {}

  span<const log_likelihood_ratio> get_data() const
  {
    ocudu_assert(completed, "Data processing is not completed.");
    return data;
  }

  pusch_codeword_buffer& get_buffer() { return *this; }

private:
  span<log_likelihood_ratio> get_next_block_view(unsigned block_size) override
  {
    ocudu_assert(!completed, "Data processing is completed.");

    block_size = std::min(block_size, static_cast<unsigned>(data.size()) - count);

    return span<log_likelihood_ratio>(data).subspan(count, block_size);
  }

  void on_new_block(span<const log_likelihood_ratio> in_block, const bit_buffer& /* scrambling_seq */) override
  {
    ocudu_assert(!completed, "Data processing is completed.");
    ocudu_assert(
        data.size() >= in_block.size() + count,
        "The sum of the block size (i.e., {}) and the current count (i.e., {}) exceeds the data size (i.e., {}).",
        in_block.size(),
        count,
        data.size());
    span<log_likelihood_ratio> block = get_next_block_view(in_block.size());

    if (block.data() != in_block.data()) {
      ocuduvec::copy(block, in_block);
    }

    count += in_block.size();
  }

  void on_end_codeword() override
  {
    ocudu_assert(!completed, "Data processing is completed.");
    ocudu_assert(data.size() == count, "Expected {} bits but only wrote {}.", data.size(), count);
    completed = true;
  }

  bool                       completed = false;
  span<log_likelihood_ratio> data;
  unsigned                   count = 0;
};

class pusch_demodulator_notifier_spy : private pusch_demodulator_notifier
{
public:
  pusch_demodulator_notifier& get_notifier() { return *this; }

  const demodulation_stats& get_stats() const { return stats.value(); }

private:
  void on_provisional_stats(unsigned i_symbol, const demodulation_stats& stats_) override { stats = stats_; }
  void on_end_stats(const demodulation_stats& stats_) override { stats = stats_; }

  std::optional<demodulation_stats> stats;
};

class dmrs_pusch_estimator_results_mock : public dmrs_pusch_estimator_results
{
public:
  dmrs_pusch_estimator_results_mock(const channel_estimate& ch_est_, const crb_bitmap& rb_mask_) :
    ch_est(ch_est_), rb_mask(rb_mask_)
  {
    ocudu_assert(ch_est.size().nof_prb == rb_mask.size(),
                 "Channel estimate size {} and RB mask size do not match.",
                 ch_est.size().nof_prb,
                 rb_mask.size());
  }

  float get_noise_variance(unsigned rx_port) const override { return ch_est.get_noise_variance(rx_port); }

  float get_rsrp(unsigned rx_port, unsigned tx_layer = 0) const override { return ch_est.get_rsrp(rx_port, tx_layer); }

  static_vector<float, MAX_PORTS> get_rsrp_all_ports(unsigned tx_layer = 0) const override
  {
    unsigned                        nof_rx_ports = ch_est.size().nof_rx_ports;
    static_vector<float, MAX_PORTS> out(nof_rx_ports);
    span<const float>               r = ch_est.get_rsrp_all_ports(tx_layer);
    for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
      out[i_port] = r[i_port];
    }
    return out;
  }

  float get_epre(unsigned rx_port) const override { return ch_est.get_epre(rx_port); }

  float get_snr(unsigned rx_port) const override { return ch_est.get_snr(rx_port); }

  float get_layer_average_snr(unsigned tx_layer = 0) const override { return ch_est.get_layer_average_snr(tx_layer); }

  phy_time_unit get_time_alignment(unsigned rx_port) const override { return ch_est.get_time_alignment(rx_port); }

  std::optional<float> get_cfo_Hz(unsigned rx_port) const override { return ch_est.get_cfo_Hz(rx_port); }

  void
  get_symbol_ch_estimate(span<cbf16_t> estimates, unsigned i_symbol, unsigned rx_port, unsigned tx_layer) const override
  {
    span<const cbf16_t> c = ch_est.get_symbol_ch_estimate(i_symbol, rx_port, tx_layer);
    ocuduvec::copy(estimates, c);
  }

  void get_symbol_ch_estimate(span<cbf16_t>                              estimates,
                              unsigned                                   i_symbol,
                              unsigned                                   rx_port,
                              unsigned                                   tx_layer,
                              const bounded_bitset<MAX_NOF_SUBCARRIERS>& re_mask) const override
  {
    span<const cbf16_t> c                  = ch_est.get_symbol_ch_estimate(i_symbol, rx_port, tx_layer);
    unsigned            expected_mask_size = rb_mask.count() * NOF_SUBCARRIERS_PER_RB;
    ocudu_assert(re_mask.size() == expected_mask_size,
                 "Wrong RE mask size {}, expected {}.",
                 re_mask.size(),
                 expected_mask_size);
    ocudu_assert(estimates.size() == re_mask.count(),
                 "The output size {} does not match the number {} of active REs in the mask.",
                 estimates.size(),
                 re_mask.count());

    span<cbf16_t>       tmp      = estimates;
    span<const cbf16_t> c_useful = c.subspan(rb_mask.find_lowest() * NOF_SUBCARRIERS_PER_RB, expected_mask_size);
    re_mask.for_each(0, re_mask.size(), [&c_useful, &tmp](unsigned i_re) {
      // Copy RE.
      tmp.front() = c_useful[i_re];

      // Advance buffer.
      tmp = tmp.last(tmp.size() - 1);
    });

    ocudu_assert(tmp.empty(), "Missing {} REs.", tmp.size());
  }

  void get_channel_state_information(channel_state_information& csi) const override
  {
    ch_est.get_channel_state_information(csi);
  }

private:
  const channel_estimate& ch_est;
  const crb_bitmap&       rb_mask;
};

} // namespace

void MexFunction::method_new(ArgumentList outputs, ArgumentList inputs)
{
  constexpr unsigned NOF_INPUTS = 2;
  if (inputs.size() != NOF_INPUTS) {
    mex_abort("Wrong number of inputs: expected {}, provided {}.", NOF_INPUTS, inputs.size());
  }

  if (inputs[1].getType() != ArrayType::CHAR) {
    mex_abort("Input 'equalizerType' must be a string.");
  }
  std::string                      eq_type_string = static_cast<CharArray>(inputs[1]).toAscii();
  channel_equalizer_algorithm_type eq_type        = channel_equalizer_algorithm_type::zf;
  if (eq_type_string == "MMSE") {
    eq_type = channel_equalizer_algorithm_type::mmse;
  } else if (eq_type_string != "ZF") {
    mex_abort("Unknown equalizer type {}.", eq_type_string);
  }

  if (!outputs.empty()) {
    mex_abort("Wrong number of outputs: expected 0, provided {}.", outputs.size());
  }

  demodulator = create_pusch_demodulator(eq_type);

  // Ensure the demodulator was created properly.
  if (!demodulator) {
    mex_abort("Cannot create OCUDU PUSCH demodulator.");
  }
}

void MexFunction::check_step_outputs_inputs(ArgumentList outputs, ArgumentList inputs)
{
  if (inputs.size() != 5) {
    mex_abort("Wrong number of inputs.");
  }

  if (inputs[1].getType() != ArrayType::COMPLEX_SINGLE) {
    mex_abort("Input 'rxSymbols' must be an array of complex floats.");
  }

  if (inputs[2].getType() != ArrayType::COMPLEX_DOUBLE) {
    mex_abort("Input 'cest' must be an array of complex doubles.");
  }

  if ((inputs[3].getType() != ArrayType::DOUBLE) || (inputs[3].getNumberOfElements() > 1)) {
    mex_abort("Input 'noiseVar' must be a scalar double.");
  }

  if ((inputs[4].getType() != ArrayType::STRUCT) || (inputs[4].getNumberOfElements() > 1)) {
    mex_abort("Input 'PUSCHDemConfig' must be a scalar structure.");
  }

  if (outputs.size() != 1) {
    mex_abort("Wrong number of outputs.");
  }
}

void MexFunction::method_step(ArgumentList outputs, ArgumentList inputs)
{
  check_step_outputs_inputs(outputs, inputs);

  // Get the PUSCH demodulator configuration from MATLAB.
  StructArray in_struct_array = inputs[4];
  Struct      in_dem_cfg      = in_struct_array[0];

  // Create a PUSCH demodulator configuration object.
  pusch_demodulator::configuration demodulator_config;

  // Set the RNTI.
  demodulator_config.rnti = in_dem_cfg["RNTI"][0];

  // Build the RB allocation bitmask (contiguous PRB allocation is assumed).
  const TypedArray<bool> rb_mask_in = in_dem_cfg["RBMask"];
  demodulator_config.rb_mask        = crb_bitmap(rb_mask_in.cbegin(), rb_mask_in.cend());

  // Set the modulation scheme.
  CharArray modulation_in       = in_dem_cfg["Modulation"];
  demodulator_config.modulation = matlab_to_ocudu_modulation(modulation_in.toAscii());

  // PUSCH time allocation.
  demodulator_config.start_symbol_index = in_dem_cfg["StartSymbolIndex"][0];
  demodulator_config.nof_symbols        = in_dem_cfg["NumSymbols"][0];

  // Build the boolean mask of OFDM symbols carrying DM-RS.
  const TypedArray<bool> dmrs_pos_in = in_dem_cfg["DMRSSymbPos"];
  demodulator_config.dmrs_symb_pos   = bounded_bitset<MAX_NSYMB_PER_SLOT>(dmrs_pos_in.begin(), dmrs_pos_in.end());

  // DM-RS configuration type.
  demodulator_config.dmrs_config_type = matlab_to_ocudu_dmrs_type(in_dem_cfg["DMRSConfigType"][0]);

  // Number of CDM Groups without data.
  demodulator_config.nof_cdm_groups_without_data = in_dem_cfg["NumCDMGroupsWithoutData"][0];

  // Scrambling identifier.
  demodulator_config.n_id = in_dem_cfg["NID"][0];

  // Number of transmit layers.
  demodulator_config.nof_tx_layers = in_dem_cfg["NumLayers"][0];

  // Transform precoding.
  demodulator_config.enable_transform_precoding = in_dem_cfg["TransformPrecoding"][0];

  // Build the Rx port list.
  const TypedArray<double> rx_ports_in = in_dem_cfg["RxPorts"];
  for (double rxp : rx_ports_in) {
    demodulator_config.rx_ports.push_back(static_cast<uint8_t>(rxp));
  }

  unsigned nof_rx_ports = demodulator_config.rx_ports.size();

  // Read the resource grid from inputs[1].
  std::unique_ptr<resource_grid> grid = read_resource_grid(inputs[1]);
  if (!grid) {
    mex_abort("Cannot create resource grid.");
  }

  // Get the channel estimates.
  const TypedArray<std::complex<double>> in_ce_cft_array = inputs[2];

  // Prepare channel estimates.
  channel_estimate::channel_estimate_dimensions ce_dims;
  ce_dims.nof_prb       = demodulator_config.rb_mask.size();
  ce_dims.nof_symbols   = MAX_NSYMB_PER_SLOT;
  ce_dims.nof_rx_ports  = nof_rx_ports;
  ce_dims.nof_tx_layers = demodulator_config.nof_tx_layers;
  channel_estimate chan_estimates(ce_dims);

  // Get the noise variance.
  float noise_var = static_cast<float>(static_cast<TypedArray<double>>(inputs[3])[0]);

  // Number of channel resource elements per receive port and layer.
  unsigned nof_ch_re_port = in_ce_cft_array.getNumberOfElements() / ce_dims.nof_rx_ports / ce_dims.nof_tx_layers;

  // Set estimated channel.
  span<const std::complex<double>> ce_port_view = to_span(in_ce_cft_array);

  for (unsigned i_tx_layer = 0; i_tx_layer != ce_dims.nof_tx_layers; ++i_tx_layer) {
    for (unsigned i_rx_port = 0; i_rx_port != ce_dims.nof_rx_ports; ++i_rx_port) {
      // Copy channel estimates for a single receive port.
      ocuduvec::copy(chan_estimates.get_path_ch_estimate(i_rx_port, i_tx_layer), ce_port_view.first(nof_ch_re_port));

      // Advance buffer.
      ce_port_view = ce_port_view.last(ce_port_view.size() - nof_ch_re_port);

      if (i_tx_layer == 0) {
        // Set noise variance.
        chan_estimates.set_noise_variance(noise_var, i_rx_port);
      }
    }
  }

  dmrs_pusch_estimator_results_mock est_results(chan_estimates, demodulator_config.rb_mask);

  // Compute expected soft output bit number.
  unsigned nof_expected_soft_output_bits = in_dem_cfg["NumOutputLLR"][0];

  TypedArray<int8_t>         out       = factory.createArray<int8_t>({nof_expected_soft_output_bits, 1});
  span<log_likelihood_ratio> soft_bits = to_span<int8_t, log_likelihood_ratio>(out);
  pusch_codeword_buffer_spy  sch_data(soft_bits);

  // Demodulate the PUSCH transmission.
  pusch_demodulator_notifier_spy notifier;
  demodulator->demodulate(
      sch_data.get_buffer(), notifier.get_notifier(), grid->get_reader(), est_results, demodulator_config);

  outputs[0] = out;
}
