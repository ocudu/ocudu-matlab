# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(short_block_encoder_test short_block_encoder_test.cpp)
target_link_libraries(short_block_encoder_test ocudu_channel_coding ocudulog gtest gtest_main)
add_test_vector(short_block_encoder_test short_block_encoder_test_data.tar.gz "")

add_executable(short_block_detector_test short_block_detector_test.cpp)
target_link_libraries(short_block_detector_test ocudu_channel_coding ocudu_upper_phy_support ocudulog gtest gtest_main)
add_test_vector(short_block_detector_test short_block_detector_test_data.tar.gz "")
