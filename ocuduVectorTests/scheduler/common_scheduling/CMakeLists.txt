#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

add_executable(prach_scheduler_vectortest prach_scheduler_vectortest.cpp)

target_link_libraries(prach_scheduler_vectortest
    ocudu_sched
    sched_test_doubles
    gtest
    ocudu_gtest_main)

target_include_directories(prach_scheduler_vectortest PRIVATE ${CMAKE_SOURCE_DIR})

add_test_vector(prach_scheduler_vectortest none "")
