// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "ssb_processor_test_data.h"
#include "ocudu/phy/upper/channel_processors/ssb/factories.h"
#include "ocudu/phy/upper/channel_processors/ssb/formatters.h"
#include "ocudu/phy/upper/signal_processors/ssb/factories.h"
#include "ocudu/ran/cyclic_prefix.h"
#include <gtest/gtest.h>

using namespace ocudu;

TEST(SSBVectorTests, SSBProcessor)
{
  std::shared_ptr<crc_calculator_factory> crc_calc_factory = create_crc_calculator_factory_sw("auto");
  ASSERT_TRUE(crc_calc_factory);

  std::shared_ptr<modulation_mapper_factory> modulator_factory = create_modulation_mapper_factory();
  ASSERT_TRUE(modulator_factory);

  std::shared_ptr<pseudo_random_generator_factory> prg_factory = create_pseudo_random_generator_sw_factory();
  ASSERT_TRUE(prg_factory);

  std::shared_ptr<polar_factory> polar_factory = create_polar_factory_sw();
  ASSERT_TRUE(polar_factory);

  std::shared_ptr<pbch_encoder_factory> pbch_enc_factory =
      create_pbch_encoder_factory_sw(crc_calc_factory, prg_factory, polar_factory);
  ASSERT_TRUE(polar_factory);

  std::shared_ptr<pbch_modulator_factory> pbch_mod_factory =
      create_pbch_modulator_factory_sw(modulator_factory, prg_factory);
  ASSERT_TRUE(pbch_mod_factory);

  std::shared_ptr<dmrs_pbch_processor_factory> dmrs_pbch_proc_factory =
      create_dmrs_pbch_processor_factory_sw(prg_factory);
  ASSERT_TRUE(dmrs_pbch_proc_factory);

  std::shared_ptr<pss_processor_factory> pss_proc_factory = create_pss_processor_factory_sw();
  ASSERT_TRUE(pss_proc_factory);

  std::shared_ptr<sss_processor_factory> sss_proc_factory = create_sss_processor_factory_sw();
  ASSERT_TRUE(sss_proc_factory);

  // Create channel processors - SSB
  ssb_processor_factory_sw_configuration ssb_factory_config;
  ssb_factory_config.encoder_factory                 = pbch_enc_factory;
  ssb_factory_config.modulator_factory               = pbch_mod_factory;
  ssb_factory_config.dmrs_factory                    = dmrs_pbch_proc_factory;
  ssb_factory_config.pss_factory                     = pss_proc_factory;
  ssb_factory_config.sss_factory                     = sss_proc_factory;
  std::shared_ptr<ssb_processor_factory> ssb_factory = create_ssb_processor_factory_sw(ssb_factory_config);
  ASSERT_TRUE(ssb_factory);

  // Create SSB processor.
  std::unique_ptr<ssb_processor> ssb = ssb_factory->create();
  ASSERT_TRUE(ssb);

  for (const test_case_t& test_case : ssb_processor_test_data) {
    // The test data was generated with 64 ports, the symbol indexes are relative to half frame and the bandwidth is
    // limited to the SSB.
    resource_grid_writer_spy grid(64, MAX_NSYMB_PER_SLOT * 5, NOF_SSB_PRBS);

    // Build the SS/PBCH block PDU. The beams that carry the transmission select the resource grid ports.
    const ssb_pdu_context& context = test_case.context;
    ssb_processor::pdu_t   pdu     = {.slot                      = context.slot,
                                      .phys_cell_id              = context.phys_cell_id,
                                      .beta_pss                  = context.beta_pss,
                                      .ssb_idx                   = context.ssb_idx,
                                      .L_max                     = context.L_max,
                                      .common_scs                = context.common_scs,
                                      .subcarrier_offset         = context.subcarrier_offset,
                                      .offset_to_pointA          = context.offset_to_pointA,
                                      .pattern_case              = context.pattern_case,
                                      .mib_payload               = context.mib_payload,
                                      .precoding_and_beamforming =
                                          precoding_beamforming_configuration::make_wideband(context.beams)};

    // Process PDU
    ssb->process(grid, pdu);

    // Load output golden data
    const std::vector<resource_grid_writer_spy::expected_entry_t> testvector_symbols = test_case.symbols.read();

    // Assert resource grid entries.
    error_type<std::string> grid_ok = grid.assert_entries(testvector_symbols);
    ASSERT_TRUE(grid_ok.has_value()) << grid_ok.error();
  }
}
