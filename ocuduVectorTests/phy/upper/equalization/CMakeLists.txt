# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(channel_equalizer_test channel_equalizer_test.cpp)
target_link_libraries(
        channel_equalizer_test
        ocudu_channel_equalizer
        ocudulog
        gtest
        gtest_main)
target_include_directories(channel_equalizer_test PRIVATE ${OCUDU_VECTORTESTS_DIR}/support)
add_test_vector(channel_equalizer_test channel_equalizer_test_data.tar.gz "")
