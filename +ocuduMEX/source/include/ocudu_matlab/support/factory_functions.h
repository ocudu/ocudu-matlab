/*
 *
 * Copyright 2021-2025 Software Radio Systems Limited
 *
 * This file is part of OCUDU-matlab.
 *
 * OCUDU-matlab is free software: you can redistribute it and/or
 * modify it under the terms of the BSD 2-Clause License.
 *
 * OCUDU-matlab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * BSD 2-Clause License for more details.
 *
 * A copy of the BSD 2-Clause License can be found in the LICENSE
 * file in the top-level directory of this distribution.
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
