// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

/// \file
/// \brief Definition of resource-grid utilities.

#include "ocudu_matlab/support/resource_grid.h"
#include "ocudu_matlab/support/factory_functions.h"
#include "ocudu_matlab/support/to_span.h"
#include "ocudu/phy/support/resource_grid_writer.h"

using namespace matlab::data;
using namespace ocudu;
using namespace ocudu_matlab;

std::unique_ptr<resource_grid> ocudu_matlab::read_resource_grid(const TypedArray<ocudu::cf_t>& in_grid)
{
  const ArrayDimensions grid_dims       = in_grid.getDimensions();
  unsigned              nof_subcarriers = grid_dims[0];
  unsigned              nof_symbols     = grid_dims[1];
  unsigned              nof_rx_ports    = 1;
  if (grid_dims.size() == 3) {
    nof_rx_ports = grid_dims[2];
  }

  std::unique_ptr<resource_grid> grid = create_resource_grid(nof_subcarriers, nof_symbols, nof_rx_ports);
  if (!grid) {
    return nullptr;
  }

  span<const cf_t> grid_view = to_span(in_grid);

  unsigned remaining_res = in_grid.getNumberOfElements();
  for (unsigned i_port = 0; i_port != nof_rx_ports; ++i_port) {
    for (unsigned i_symbol = 0; i_symbol != nof_symbols; ++i_symbol) {
      span<const cf_t> symbol_view = grid_view.first(nof_subcarriers);
      remaining_res -= nof_subcarriers;
      grid_view = grid_view.last(remaining_res);

      grid->get_writer().put(i_port, i_symbol, 0, symbol_view);
    }
  }

  return grid;
}
