# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

set_directory_properties(PROPERTIES LABELS "phy")

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

include_directories(${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)

add_executable(pdsch_encoder_test pdsch_encoder_test.cpp)
set(PDSCH_ENCODER_LIBRARIES ocudu_channel_processors ocudulog)

if (ENABLE_PDSCH_HWACC)
    set_source_files_properties(pdsch_encoder_test.cpp PROPERTIES COMPILE_DEFINITIONS "HWACC_PDSCH_ENABLED")
    list(APPEND PDSCH_ENCODER_LIBRARIES ocudu_hal_pdsch)
endif (ENABLE_PDSCH_HWACC)

target_link_libraries(pdsch_encoder_test ${PDSCH_ENCODER_LIBRARIES})
add_test_vector(pdsch_encoder_test pdsch_encoder_test_data.tar.gz "")

add_executable(pdsch_modulator_test pdsch_modulator_test.cpp)
target_link_libraries(pdsch_modulator_test ocudu_channel_processors ocudu_channel_precoder ocudulog gtest gtest_main)
add_test_vector(pdsch_modulator_test pdsch_modulator_test_data.tar.gz "")

add_executable(pdsch_processor_vectortest pdsch_processor_vectortest.cpp)
set(PDSCH_PROCESSOR_LIBRARIES ocudu_channel_processors ocudu_channel_precoder ocudulog gtest gtest_main)
target_include_directories(pdsch_processor_vectortest PRIVATE ${CMAKE_SOURCE_DIR}/tests/unittests/phy/upper/channel_processors/pdsch)

if (ENABLE_PDSCH_HWACC)
    set_source_files_properties(pdsch_processor_vectortest.cpp PROPERTIES COMPILE_DEFINITIONS "HWACC_PDSCH_ENABLED")
    list(APPEND PDSCH_PROCESSOR_LIBRARIES ocudu_hal_pdsch)
endif (ENABLE_PDSCH_HWACC)

target_link_libraries(pdsch_processor_vectortest ${PDSCH_PROCESSOR_LIBRARIES})
add_test_vector(pdsch_processor_vectortest pdsch_processor_test_data.tar.gz "")
