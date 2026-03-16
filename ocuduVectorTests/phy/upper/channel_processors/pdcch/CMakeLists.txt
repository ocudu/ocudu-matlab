# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

include_directories(${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)

add_executable(pdcch_encoder_test pdcch_encoder_test.cpp)
target_link_libraries(pdcch_encoder_test ocudu_channel_processors ocudulog)
add_test_vector(pdcch_encoder_test pdcch_encoder_test_data.tar.gz "")

add_executable(pdcch_modulator_test pdcch_modulator_test.cpp)
target_link_libraries(pdcch_modulator_test
        ocudu_channel_coding
        ocudu_channel_modulation
        ocudu_channel_precoder
        ocudu_channel_processors
        ocudu_sequence_generators
        ocudu_signal_processors
        ocudulog)
add_test_vector(pdcch_modulator_test pdcch_modulator_test_data.tar.gz "")

add_executable(pdcch_processor_vectortest pdcch_processor_vectortest.cpp)
target_link_libraries(pdcch_processor_vectortest ocudu_channel_processors ocudu_channel_precoder ocudulog gtest gtest_main)
add_test_vector(pdcch_processor_vectortest pdcch_processor_test_data.tar.gz "")
