# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(low_papr_sequence_generator_test low_papr_sequence_generator_test.cpp)
target_link_libraries(low_papr_sequence_generator_test ocudu_sequence_generators ocuduvec ocudulog ocudu_support gtest gtest_main)
add_test_vector(low_papr_sequence_generator_test low_papr_sequence_generator_test_data.tar.gz "")
