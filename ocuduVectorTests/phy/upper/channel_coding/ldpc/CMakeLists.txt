# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(ldpc_enc_dec_vectortest ldpc_enc_dec_vectortest.cpp)
target_link_libraries(ldpc_enc_dec_vectortest ocudu_channel_coding ocudulog gtest gtest_main)
add_test_vector(ldpc_enc_dec_vectortest ldpc_encoder_test_data.tar.gz "")

add_executable(ldpc_rm_vectortest ldpc_rm_vectortest.cpp)
target_link_libraries(ldpc_rm_vectortest ocudu_channel_coding ocudulog gtest gtest_main)
add_test_vector(ldpc_rm_vectortest ldpc_rate_matcher_test_data.tar.gz "")

add_executable(ldpc_segmenter_vectortest ldpc_segmenter_vectortest.cpp)
target_link_libraries(ldpc_segmenter_vectortest ocudu_channel_coding ocudulog gtest gtest_main)
add_test_vector(ldpc_segmenter_vectortest ldpc_segmenter_test_data.tar.gz "")
