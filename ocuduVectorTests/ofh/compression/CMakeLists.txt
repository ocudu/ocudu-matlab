# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

add_executable(ofh_compression_test ofh_compression_test.cpp)
target_link_libraries(ofh_compression_test ocudu_ofh_compression ocudulog gtest gtest_main)
target_include_directories(ofh_compression_test PRIVATE ${CMAKE_SOURCE_DIR}/lib/ofh/compression)
add_test_vector(ofh_compression_test ofh_compression_test_data.tar.gz "")
