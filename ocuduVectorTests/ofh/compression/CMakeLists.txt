#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

add_executable(ofh_compression_test ofh_compression_test.cpp)
target_link_libraries(ofh_compression_test ocudu_ofh_compression ocudulog gtest gtest_main)
target_include_directories(ofh_compression_test PRIVATE ${CMAKE_SOURCE_DIR}/lib/ofh/compression)
add_test_vector(ofh_compression_test ofh_compression_test_data.tar.gz "")
