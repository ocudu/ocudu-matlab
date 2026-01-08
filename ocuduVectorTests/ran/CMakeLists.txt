#
# Copyright 2021-2026 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

add_executable(pusch_tpmi_select_test pusch/pusch_tpmi_select_test.cpp)
target_link_libraries(pusch_tpmi_select_test ocudu_ran ocudulog gtest gtest_main)
add_test_vector(pusch_tpmi_select_test none "")

add_executable(ulsch_info_test pusch/ulsch_info_test.cpp)
target_link_libraries(ulsch_info_test ocudu_ran ocudulog gtest gtest_main)
add_test_vector(ulsch_info_test none "")

add_executable(tbs_calculator_test sch/tbs_calculator_test.cpp)
target_link_libraries(tbs_calculator_test ocudu_sched ocudulog)
add_test_vector(tbs_calculator_test none "")

add_executable(pdcch_candidates_common pdcch/pdcch_candidates_common_test.cpp)
target_link_libraries(pdcch_candidates_common ocudu_support ocudu_ran gtest gtest_main)
add_test_vector(pdcch_candidates_common none "")

add_executable(pdcch_candidates_ue pdcch/pdcch_candidates_ue_test.cpp)
target_link_libraries(pdcch_candidates_ue ocudu_support ocudu_ran gtest gtest_main)
add_test_vector(pdcch_candidates_ue none "")
