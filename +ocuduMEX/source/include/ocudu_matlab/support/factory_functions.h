/*
 *
 * Copyright 2021-2026 Software Radio Systems Limited
 *
 * By using this file, you agree to the terms and conditions set
 * forth in the LICENSE file which can be found at the top level of
 * the distribution.
 *
 */

/// \file
/// \brief Factory functions for OCUDU classes.

#pragma once

#include "ocudu/phy/support/resource_grid.h"
#include "ocudu/phy/support/support_factories.h"

/// Creates a resource grid for the given number of subcarriers, OFDM symbols and antenna ports.
inline std::unique_ptr<ocudu::resource_grid>
create_resource_grid(unsigned nof_subc, unsigned nof_symbols, unsigned nof_ports)
{
  using namespace ocudu;

  std::shared_ptr<resource_grid_factory> rg_factory = create_resource_grid_factory();
  if (!rg_factory) {
    return nullptr;
  }
  return rg_factory->create(nof_ports, nof_symbols, nof_subc);
}
