# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

include_directories(${CMAKE_SOURCE_DIR}/tests/unittests/phy/support)

add_executable(pbch_encoder_test pbch_encoder_test.cpp)
target_link_libraries(pbch_encoder_test ocudu_channel_processors ocudulog)
add_test_vector(pbch_encoder_test pbch_encoder_test_data.tar.gz "")

add_executable(pbch_modulator_test pbch_modulator_test.cpp)
target_link_libraries(pbch_modulator_test ocudu_channel_processors ocudulog)
add_test_vector(pbch_modulator_test pbch_modulator_test_data.tar.gz "")

add_executable(ssb_processor_vectortest ssb_processor_vectortest.cpp)
target_link_libraries(ssb_processor_vectortest ocudu_channel_processors ocudulog)
add_test_vector(ssb_processor_vectortest ssb_processor_test_data.tar.gz "")
