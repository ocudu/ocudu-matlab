# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

set_directory_properties(PROPERTIES LABELS "phy")

add_executable(transform_precoder_vectortest transform_precoder_vectortest.cpp)

target_link_libraries(
        transform_precoder_vectortest
        ocudu_transform_precoding
        ocudu_dft
        ocudulog
        ocuduvec
        gtest
        gtest_main)

add_test_vector(transform_precoder_vectortest transform_precoder_test_data.tar.gz "")
