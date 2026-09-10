// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "dmrs_pbch_processor_test_data.h"
#include "ocudu/phy/upper/signal_processors/ssb/factories.h"
#include "ocudu/ran/ssb/ssb_properties.h"
#include <gtest/gtest.h>

using namespace ocudu;

TEST(SSBVectorTests, PBCHDMRS)
{
  std::shared_ptr<pseudo_random_generator_factory> prg_factory = create_pseudo_random_generator_sw_factory();
  ASSERT_TRUE(prg_factory);

  std::shared_ptr<dmrs_pbch_processor_factory> dmrs_pbch_factory = create_dmrs_pbch_processor_factory_sw(prg_factory);
  ASSERT_TRUE(dmrs_pbch_factory);

  // Create DMRS-PBCH processor
  std::unique_ptr<dmrs_pbch_processor> dmrs_pbch = dmrs_pbch_factory->create();
  ASSERT_TRUE(dmrs_pbch);

  for (const test_case_t& test_case : dmrs_pbch_processor_test_data) {
    // Create resource grid
    resource_grid_writer_spy grid(
        test_case.config.precoding_and_beamforming.get_nof_beams(), NOF_SSB_SYMB, NOF_SSB_PRBS);

    // Map DMRS-PBCH using the test case arguments
    dmrs_pbch->map(grid, test_case.config);

    // Load output golden data
    const std::vector<resource_grid_writer_spy::expected_entry_t> testvector_symbols = test_case.symbols.read();

    // Assert resource grid entries.
    error_type<std::string> entries_ok = grid.assert_entries(testvector_symbols);
    ASSERT_TRUE(entries_ok.has_value()) << entries_ok.error();
  }
}
