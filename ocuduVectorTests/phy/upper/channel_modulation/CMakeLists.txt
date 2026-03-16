# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(demodulation_mapper_test demodulation_mapper_test.cpp)
target_link_libraries(demodulation_mapper_test ocudu_channel_modulation ocuduvec ocudulog gtest gtest_main)
target_include_directories(demodulation_mapper_test PRIVATE ${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)
add_test_vector(demodulation_mapper_test demodulation_mapper_test_data.tar.gz "")

add_executable(modulation_mapper_test modulation_mapper_test.cpp)
target_link_libraries(modulation_mapper_test ocudu_channel_modulation ocuduvec ocudulog gtest gtest_main)
target_include_directories(modulation_mapper_test PRIVATE ${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)
add_test_vector(modulation_mapper_test modulation_mapper_test_data.tar.gz "")
