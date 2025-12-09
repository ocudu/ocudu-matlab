add_executable(prach_scheduler_vectortest prach_scheduler_vectortest.cpp)

target_link_libraries(prach_scheduler_vectortest
    ocudu_sched
    sched_test_doubles
    gtest
    gtest_main)

target_include_directories(prach_scheduler_vectortest PRIVATE ${CMAKE_SOURCE_DIR})

add_test_vector(prach_scheduler_vectortest none "")
