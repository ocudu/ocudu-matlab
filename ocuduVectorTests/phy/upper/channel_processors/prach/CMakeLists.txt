# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(prach_detector_vectortest prach_detector_vectortest.cpp)
target_link_libraries(prach_detector_vectortest ocudu_prach_detector ocudu_dft ocudu_phy_support ocudulog gtest gtest_main)
target_include_directories(prach_detector_vectortest PRIVATE ${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)
add_test_vector(prach_detector_vectortest prach_detector_test_data.tar.gz "")

add_executable(prach_generator_vectortest prach_generator_vectortest.cpp)
target_link_libraries(prach_generator_vectortest ocudu_channel_processors ocudu_dft ocudulog gtest gtest_main)
add_test_vector(prach_generator_vectortest prach_generator_test_data.tar.gz "")
