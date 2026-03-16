# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI
# Portions of this file may implement 3GPP specifications, which may be subject
# to additional licensing requirements.

matlab_add_mex(
    NAME prach_detector_mex
    SRC prach_detector_mex.cpp
    R2018a
)

target_link_libraries(prach_detector_mex
        ocudu::ocudu_prach_detector
        ocudu::ocudu_phy_support
        ocudu::ocudu_dft)

install(TARGETS prach_detector_mex
    DESTINATION "+phy/@ocuduPRACHDetector"
)

matlab_add_mex(
    NAME pusch_decoder_mex
    SRC pusch_decoder_mex.cpp
    R2018a
)

target_link_libraries(pusch_decoder_mex ocudu::ocudu_channel_processors)

install(TARGETS pusch_decoder_mex
    DESTINATION "+phy/@ocuduPUSCHDecoder"
)

matlab_add_mex(
    NAME pusch_demodulator_mex
    SRC pusch_demodulator_mex.cpp
    R2018a
)

target_link_libraries(pusch_demodulator_mex
    ocudu_matlab::resource_grid
    ocudu::ocudu_channel_processors
    ocudu::ocudu_channel_equalizer
    ocudu::ocudu_channel_precoder
    ocudu::ocudu_dft
    ocudu::ocudu_transform_precoding
)

install(TARGETS pusch_demodulator_mex
    DESTINATION "+phy/@ocuduPUSCHDemodulator"
)

matlab_add_mex(
    NAME pucch_processor_mex
    SRC  pucch_processor_mex.cpp
    R2018a
)

target_link_libraries(pucch_processor_mex
    ocudu_matlab::resource_grid
    ocudu::ocudu_channel_processors
    ocudu::ocudu_channel_equalizer
    ocudu::ocudu_phy_support
    ocudu::ocudu_transform_precoding
)

install(TARGETS pucch_processor_mex
    DESTINATION "+phy/@ocuduPUCCHProcessor"
)

# Tell the installed MEXs where to find libresource_grid.so.
set_target_properties(pucch_processor_mex pusch_demodulator_mex
   PROPERTIES INSTALL_RPATH "${CMAKE_BINARY_DIR}/lib/support"
)
