# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI
# Portions of this file may implement 3GPP specifications, which may be subject
# to additional licensing requirements.

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
