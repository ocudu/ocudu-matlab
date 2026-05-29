// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "ptrs_pdsch_generator_test_data.h"
#include "resource_grid_test_doubles.h"
#include "ocudu/phy/support/support_factories.h"
#include "ocudu/phy/upper/signal_processors/ptrs/ptrs_pdsch_generator.h"
#include "ocudu/phy/upper/signal_processors/ptrs/ptrs_pdsch_generator_factory.h"
#include "ocudu/ran/precoding/precoding_codebooks.h"
#include <fmt/ostream.h>
#include <gtest/gtest.h>

using namespace ocudu;

namespace ocudu {

std::ostream& operator<<(std::ostream& os, const test_case_t& test_case)
{
  fmt::print(os,
             "slot={} rnti={} dmrs={} k_rb={} id={} n_scid={} amplitude={} dmrs={} time_allocation={} freq_density={} "
             "time_density={} re_offset={} nof_layers={}",
             test_case.slot,
             to_value(test_case.rnti),
             test_case.dmrs_type,
             test_case.reference_point_k_rb,
             test_case.scrambling_id,
             test_case.n_scid,
             test_case.amplitude,
             test_case.dmrs_symbols_mask,
             test_case.time_allocation,
             to_string(test_case.freq_density),
             to_string(test_case.time_density),
             to_string(test_case.re_offset),
             test_case.nof_layers);
  return os;
}

} // namespace ocudu

namespace {

class PtrsPdschGeneratorFixture : public ::testing::TestWithParam<test_case_t>
{
protected:
  static void SetUpTestSuite()
  {
    if (ptrs_pdsch_gen) {
      return;
    }

    std::shared_ptr<pseudo_random_generator_factory> pseudo_random_gen_factory =
        create_pseudo_random_generator_sw_factory();
    report_fatal_error_if_not(pseudo_random_gen_factory, "Failed to create factory.");

    std::shared_ptr<channel_precoder_factory> precoding_factory = create_channel_precoder_factory("auto");
    report_fatal_error_if_not(precoding_factory, "Failed to create factory.");

    std::shared_ptr<resource_grid_mapper_factory> rg_mapper_factory_ =
        create_resource_grid_mapper_factory(precoding_factory);
    report_fatal_error_if_not(rg_mapper_factory_, "Failed to create factory.");

    rg_mapper_factory = rg_mapper_factory_;

    std::shared_ptr<ptrs_pdsch_generator_factory> ptrs_pdsch_gen_factory =
        create_ptrs_pdsch_generator_generic_factory(pseudo_random_gen_factory, rg_mapper_factory_);
    report_fatal_error_if_not(ptrs_pdsch_gen_factory, "Failed to create factory.");

    ptrs_pdsch_gen = ptrs_pdsch_gen_factory->create();
    report_fatal_error_if_not(ptrs_pdsch_gen, "Failed to create factory.");
  }

  static std::unique_ptr<ptrs_pdsch_generator>         ptrs_pdsch_gen;
  static std::shared_ptr<resource_grid_mapper_factory> rg_mapper_factory;
};

std::unique_ptr<ptrs_pdsch_generator>         PtrsPdschGeneratorFixture::ptrs_pdsch_gen    = nullptr;
std::shared_ptr<resource_grid_mapper_factory> PtrsPdschGeneratorFixture::rg_mapper_factory = nullptr;

} // namespace

TEST_P(PtrsPdschGeneratorFixture, FromTestVector)
{
  // Prepare resource grid and resource grid mapper spies.
  resource_grid_writer_spy grid(precoding_constants::MAX_NOF_PORTS, MAX_NSYMB_PER_SLOT, MAX_NOF_PRBS);

  const test_case_t&                  test_case = GetParam();
  ptrs_pdsch_generator::configuration config;
  config.slot                 = test_case.slot;
  config.rnti                 = test_case.rnti;
  config.dmrs_type            = test_case.dmrs_type;
  config.reference_point_k_rb = test_case.reference_point_k_rb;
  config.scrambling_id        = test_case.scrambling_id;
  config.n_scid               = test_case.n_scid;
  config.amplitude            = test_case.amplitude;
  config.dmrs_symbols_mask    = test_case.dmrs_symbols_mask;
  config.rb_mask              = test_case.rb_mask;
  config.time_allocation      = test_case.time_allocation;
  config.freq_density         = test_case.freq_density;
  config.time_density         = test_case.time_density;
  config.re_offset            = test_case.re_offset;
  config.precoding            = precoding_configuration::make_wideband(make_identity(test_case.nof_layers));

  // Generate signal.
  ptrs_pdsch_gen->generate(grid, config);

  // Load output golden data.
  const std::vector<resource_grid_writer_spy::expected_entry_t> testvector_symbols = test_case.symbols.read();

  // Assert resource grid entries.
  grid.assert_entries(testvector_symbols, std::sqrt(config.precoding.get_nof_ports()));
}

// Creates test suite that combines all possible parameters.
INSTANTIATE_TEST_SUITE_P(PtrsPdschGenerator,
                         PtrsPdschGeneratorFixture,
                         ::testing::ValuesIn(ptrs_pdsch_generator_test_data));
