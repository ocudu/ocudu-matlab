// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "pbch_modulator_test_data.h"
#include "ocudu/phy/upper/channel_processors/ssb/factories.h"

using namespace ocudu;

TEST(SSBVectorTests, PBCHModulator)
{
  std::shared_ptr<modulation_mapper_factory> modulator_factory = create_modulation_mapper_factory();
  ASSERT_TRUE(modulator_factory);

  std::shared_ptr<pseudo_random_generator_factory> prg_factory = create_pseudo_random_generator_sw_factory();
  ASSERT_TRUE(prg_factory);

  std::shared_ptr<pbch_modulator_factory> pbch_factory =
      create_pbch_modulator_factory_sw(modulator_factory, prg_factory);
  ASSERT_TRUE(modulator_factory);

  std::unique_ptr<pbch_modulator> modulator = pbch_factory->create();
  ASSERT_TRUE(modulator);

  for (const test_case_t& test_case : pbch_modulator_test_data) {
    resource_grid_writer_spy grid(
        test_case.config.precoding_and_beamforming.get_nof_beams(), NOF_SSB_SYMB, NOF_SSB_PRBS);

    // Load input data
    const std::vector<uint8_t> testvector_data = test_case.data.read();

    // Run the entity process
    modulator->put(testvector_data, grid, test_case.config);

    // Load output golden data
    const std::vector<resource_grid_writer_spy::expected_entry_t> testvector_symbols = test_case.symbols.read();

    // Assert resource grid entries.
    error_type<std::string> grid_ok = grid.assert_entries(testvector_symbols);
    ASSERT_TRUE(grid_ok.has_value()) << grid_ok.error();
  }
}
