# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

add_library(resource_grid SHARED resource_grid.cpp)
target_include_directories(resource_grid PUBLIC ${Matlab_INCLUDE_DIRS})
target_link_libraries(resource_grid PRIVATE
    ocudu::ocudu_phy_support
    ocudu::fmt
)

add_library(ocudu_matlab::resource_grid ALIAS resource_grid)
