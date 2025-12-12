#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

matlab_add_mex(
    NAME multiport_channel_estimator_mex
    SRC multiport_channel_estimator_mex.cpp
    R2018a
)

target_link_libraries(multiport_channel_estimator_mex
    ocudu_matlab::resource_grid
    ocudu::ocudu_channel_estimator
    ocudu::ocudu_dft
    ocudu::fmt
)

# Tell the installed MEXs where to find libresource_grid.so.
set_target_properties(multiport_channel_estimator_mex
   PROPERTIES INSTALL_RPATH "${CMAKE_BINARY_DIR}/lib/support"
)

install(TARGETS multiport_channel_estimator_mex
    DESTINATION "+phy/@ocuduMultiPortChannelEstimator"
)
