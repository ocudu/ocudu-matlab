# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

add_executable(prach_scheduler_vectortest prach_scheduler_vectortest.cpp)

target_link_libraries(prach_scheduler_vectortest
    ocudu_sched
    sched_test_doubles
    gtest
    ocudu_gtest_main)

target_include_directories(prach_scheduler_vectortest PRIVATE ${CMAKE_SOURCE_DIR})

add_test_vector(prach_scheduler_vectortest none "")
