# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test_data)
set(TEST_DATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/test_data)

set_directory_properties(PROPERTIES LABELS "phy")

if (USE_PHY_TESTVECTORS)
    add_executable(uci_decoder_test uci_decoder_test.cpp)
    target_link_libraries(uci_decoder_test ocudu_channel_processors ocudu_channel_coding ocudu_upper_phy_support gtest gtest_main)
    add_test_vector(uci_decoder_test uci_decoder_test_data.tar.gz "")
endif (USE_PHY_TESTVECTORS)
