#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

add_library(resource_grid SHARED resource_grid.cpp)
target_include_directories(resource_grid PUBLIC ${Matlab_INCLUDE_DIRS})
target_link_libraries(resource_grid PRIVATE
    ocudu::ocudu_phy_support
    ocudu::fmt
)

add_library(ocudu_matlab::resource_grid ALIAS resource_grid)
