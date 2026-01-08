#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_subdirectory(transform_precoding)

add_executable(dft_processor_vectortest dft_processor_vectortest.cpp)
target_link_libraries(dft_processor_vectortest ocudulog ocudu_dft gtest gtest_main)
target_include_directories(dft_processor_vectortest PRIVATE ${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)
add_test_vector(dft_processor_vectortest dft_processor_test_data.tar.gz "")
