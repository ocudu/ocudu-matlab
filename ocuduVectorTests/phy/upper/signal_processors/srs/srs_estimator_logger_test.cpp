// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#include "resource_grid_test_doubles.h"
#include "srs_estimator_test_doubles.h"
#include "ocudu/ocudulog/ocudulog.h"
#include "ocudu/phy/upper/signal_processors/srs/formatters.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator_configuration.h"
#include "ocudu/phy/upper/signal_processors/srs/srs_estimator_factory.h"
#include "gtest/gtest.h"

using namespace ocudu;

namespace {

// Valid SRS configuration used as a base for the test case.
const srs_estimator_configuration base_config = {std::nullopt,
                                                 {0, 130, 8, 0},
                                                 {srs_resource_configuration::one_two_four_enum(2),
                                                  srs_nof_symbols(1),
                                                  12,
                                                  17,
                                                  647,
                                                  2,
                                                  tx_comb_size(2),
                                                  1,
                                                  1,
                                                  66,
                                                  1,
                                                  3,
                                                  srs_group_or_sequence_hopping::neither,
                                                  {}},
                                                 {0}};

class srs_estimator_dummy_factory : public srs_estimator_factory
{
public:
  std::unique_ptr<srs_estimator> create() override { return std::make_unique<srs_estimator_dummy>(); }

  std::unique_ptr<srs_estimator_configuration_validator> create_validator() override { return nullptr; }
};

TEST(srsEstimator, LoggerInfoTest)
{
  ocudulog::init();

  ocudulog::basic_logger& logger = ocudulog::fetch_basic_logger("PHY", true);
  logger.set_level(ocudulog::basic_levels::info);

  std::shared_ptr<srs_estimator_factory> factory = std::make_shared<srs_estimator_dummy_factory>();

  std::unique_ptr<srs_estimator> estimator = factory->create(logger);
  ASSERT_NE(estimator, nullptr);

  // Prepare resource grid and resource grid mapper spies.
  resource_grid_reader_spy grid(0, 0, 0);

  estimator->estimate(grid, base_config);
}

TEST(srsEstimator, LoggerDebugTest)
{
  ocudulog::init();

  ocudulog::basic_logger& logger = ocudulog::fetch_basic_logger("PHY", true);
  logger.set_level(ocudulog::basic_levels::debug);

  std::shared_ptr<srs_estimator_factory> factory = std::make_shared<srs_estimator_dummy_factory>();

  std::unique_ptr<srs_estimator> estimator = factory->create(logger);
  ASSERT_NE(estimator, nullptr);

  // Prepare resource grid and resource grid mapper spies.
  resource_grid_reader_spy grid(0, 0, 0);

  estimator->estimate(grid, base_config);
}

} // namespace
