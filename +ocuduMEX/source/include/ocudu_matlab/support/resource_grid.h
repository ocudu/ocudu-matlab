// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

/// \file
/// \brief Declaration of resource-grid utilities.

#pragma once

#include "ocudu/adt/complex.h"
#include "ocudu/phy/support/resource_grid.h"
#include "MatlabDataArray/TypedArray.hpp"

namespace ocudu_matlab {

/// \brief Creates a resource grid from a MATLAB multidimensional array.
///
/// \param[in] in_grid  The resource grid as a multidimensional (2D or 3D) array of complex floats, as passed by MATLAB
///                     to the MEX.
/// \return A unique pointer to the newly created resource grid object.
std::unique_ptr<ocudu::resource_grid> read_resource_grid(const matlab::data::TypedArray<ocudu::cf_t>& in_grid);

} // namespace ocudu_matlab
