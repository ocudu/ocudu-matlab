# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

add_executable(pusch_tpmi_select_vectortest pusch/pusch_tpmi_select_vectortest.cpp)
target_link_libraries(pusch_tpmi_select_vectortest ocudu_ran ocudulog gtest gtest_main)
add_test_vector(pusch_tpmi_select_vectortest none "")

add_executable(ulsch_info_vectortest pusch/ulsch_info_vectortest.cpp)
target_link_libraries(ulsch_info_vectortest ocudu_ran ocudulog gtest gtest_main)
add_test_vector(ulsch_info_vectortest none "")

add_executable(tbs_calculator_vectortest sch/tbs_calculator_vectortest.cpp)
target_link_libraries(tbs_calculator_vectortest ocudu_sched ocudulog gtest gtest_main)
add_test_vector(tbs_calculator_vectortest none "")

add_executable(pdcch_candidates_common_vectortest pdcch/pdcch_candidates_common_vectortest.cpp)
target_link_libraries(pdcch_candidates_common_vectortest ocudu_support ocudu_ran gtest gtest_main)
add_test_vector(pdcch_candidates_common_vectortest none "")

add_executable(pdcch_candidates_ue_vectortest pdcch/pdcch_candidates_ue_vectortest.cpp)
target_link_libraries(pdcch_candidates_ue_vectortest ocudu_support ocudu_ran gtest gtest_main)
add_test_vector(pdcch_candidates_ue_vectortest none "")
