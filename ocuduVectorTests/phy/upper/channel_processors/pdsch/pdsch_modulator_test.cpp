// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "pdsch_modulator_test_data.h"
#include "ocudu/ocuduvec/bit.h"
#include "ocudu/phy/support/precoding_formatters.h"
#include "ocudu/phy/support/re_pattern_formatters.h"
#include "ocudu/phy/support/support_factories.h"
#include "ocudu/phy/upper/channel_processors/pdsch/factories.h"
#include "ocudu/ran/pdsch/pdsch_constants.h"
#include <gtest/gtest.h>

using namespace ocudu;

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(
      os,
      "rnti={} bwp={} mod1={} mod2={} freq={} time={} dmrs={}/{} ncgwd={} n_id={} scaling={:.1f} rvd={} nof_layers={}",
      test_case.context.rnti,
      test_case.context.bwp,
      to_string(test_case.context.modulation1),
      test_case.context.modulation2.has_value() ? to_string(*test_case.context.modulation2) : "n/a",
      test_case.context.freq_allocation,
      test_case.context.time_alloc,
      test_case.context.dmrs_symb_pos,
      test_case.context.dmrs_type,
      test_case.context.nof_cdm_groups_without_data,
      test_case.context.n_id,
      test_case.context.scaling,
      test_case.context.reserved.get_re_patterns(),
      test_case.context.nof_layers);
  return os;
}

} // namespace ocudu

namespace {

class PdschModulatorFixture : public ::testing::TestWithParam<test_case_t>
{
protected:
  static void SetUpTestSuite()
  {
    std::shared_ptr<modulation_mapper_factory> modulator_factory = create_modulation_mapper_factory();
    report_fatal_error_if_not(modulator_factory, "Failed to create modulation mapper factory.");

    std::shared_ptr<pseudo_random_generator_factory> prg_factory = create_pseudo_random_generator_sw_factory();
    report_fatal_error_if_not(prg_factory, "Failed to create pseudo-random sequence generator factory.");

    std::shared_ptr<channel_precoder_factory> precoding_factory = create_channel_precoder_factory("auto");
    report_fatal_error_if_not(precoding_factory, "Failed to create precoder factory.");

    std::shared_ptr<resource_grid_mapper_factory> rg_mapper_factory =
        create_resource_grid_mapper_factory(precoding_factory);
    report_fatal_error_if_not(rg_mapper_factory, "Failed to create RG mapper factory.");

    std::shared_ptr<pdsch_modulator_factory> pdsch_factory =
        create_pdsch_modulator_factory_sw(modulator_factory, prg_factory, rg_mapper_factory);
    report_fatal_error_if_not(rg_mapper_factory, "Failed to create PDSCH modulator factory.");

    pdsch = pdsch_factory->create();
    report_fatal_error_if_not(pdsch, "Failed to create PDSCH modulator.");
  }

  static std::unique_ptr<pdsch_modulator> pdsch;
};

std::unique_ptr<pdsch_modulator> PdschModulatorFixture::pdsch = nullptr;

TEST_P(PdschModulatorFixture, VectorTest)
{
  const test_case_t& test_case = GetParam();
  const context_t&   context   = test_case.context;
  unsigned           max_prb   = context.bwp.stop();

  // Number of layers for the transmission in the range of [1...8].
  unsigned nof_layers = context.nof_layers;

  // For more than four layers, two codewords are modulated.
  ASSERT_TRUE((nof_layers <= 4) || (context.modulation2.has_value()))
      << fmt::format("For a {}-layer transmission, the modulation for the second codeword is required.", nof_layers);

  // Number of codewords modulated.
  unsigned nof_codewords = (nof_layers > 4) ? 2 : 1;

  // Number of OFDM symbols per slot.
  unsigned max_symb = get_nsymb_per_slot(cyclic_prefix::NORMAL);

  // Build the precoding configuration for both codewords.
  precoding_configuration precoding = precoding_configuration::make_wideband(make_identity(nof_layers));

  // Build the modulator config from the test parameters.
  pdsch_modulator::config_t config = {.rnti                        = context.rnti,
                                      .bwp                         = context.bwp,
                                      .modulation1                 = context.modulation1,
                                      .modulation2                 = context.modulation2,
                                      .freq_allocation             = context.freq_allocation,
                                      .time_alloc                  = context.time_alloc,
                                      .dmrs_symb_pos               = context.dmrs_symb_pos,
                                      .dmrs_type                   = context.dmrs_type,
                                      .nof_cdm_groups_without_data = context.nof_cdm_groups_without_data,
                                      .n_id                        = context.n_id,
                                      .scaling                     = context.scaling,
                                      .reserved                    = context.reserved,
                                      .precoding                   = precoding};

  // Populate the list of resource grid ports for this transmission. Since the logical ports map physical ports, the
  // list is trivial.
  static_vector<uint8_t, precoding_constants::MAX_NOF_PORTS> ports(precoding.get_nof_ports());
  std::iota(ports.begin(), ports.end(), 0);
  config.ports = ports;

  // Prepare resource grid spy.
  resource_grid_writer_spy grid((nof_layers > 4) ? 8 : 4, max_symb, max_prb);

  // Read all input data.
  std::vector<uint8_t> data = test_case.data.read();

  // Codeword size in bits.
  unsigned codeword_size = data.size() / nof_codewords;

  // Packed codewords.
  static_vector<dynamic_bit_buffer, pdsch_constants::MAX_NOF_CODEWORDS> packed_codewords;

  // Views over the packed codewords for modulation.
  static_vector<bit_buffer, pdsch_constants::MAX_NOF_CODEWORDS> codewords;

  for (unsigned i_codeword = 0; i_codeword != nof_codewords; ++i_codeword) {
    // Get a view over this codeword data.
    span<uint8_t> codeword = span(data.data(), data.size()).subspan(i_codeword * codeword_size, codeword_size);

    // Pack codeword.
    dynamic_bit_buffer& packed_codeword = packed_codewords.emplace_back(codeword_size);
    ocuduvec::bit_pack(packed_codeword, codeword);

    codewords.push_back(packed_codeword);
  }

  // Modulate.
  pdsch->modulate(grid, codewords, config);

  // Read resource grid data.
  std::vector<resource_grid_writer_spy::expected_entry_t> rg_entries = test_case.symbols.read();

  // Assert resource grid entries.
  grid.assert_entries(rg_entries, std::sqrt(static_cast<float>(nof_layers)));
}

INSTANTIATE_TEST_SUITE_P(PdschProcessorVectortest,
                         PdschModulatorFixture,
                         ::testing::ValuesIn(pdsch_modulator_test_data));

} // namespace
