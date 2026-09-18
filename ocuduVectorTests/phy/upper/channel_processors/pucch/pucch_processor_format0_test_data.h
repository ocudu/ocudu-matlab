// SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
// SPDX-License-Identifier: BSD-3-Clause-Open-MPI

#pragma once

// This file was generated using the following MATLAB class on 21-09-2026 (seed 0):
//   + "ocuduPUCCHProcessorFormat0Unittest.m"

#include "resource_grid_test_doubles.h"
#include "ocudu/phy/upper/channel_processors/pucch/pucch_processor.h"
#include "ocudu/support/file_vector.h"
#include <optional>
#include <vector>

namespace ocudu {

struct pucch_entry {
  pucch_processor::format0_configuration config;
  std::vector<uint8_t>                   ack_bits;
  std::optional<uint8_t>                 sr;
};
struct test_case_t {
  pucch_entry                                             entry;
  file_vector<resource_grid_reader_spy::expected_entry_t> grid;
};

static const std::vector<test_case_t> pucch_processor_format0_test_data = {
    // clang-format off
  {{{std::nullopt, {0, 1008}, 9, cyclic_prefix::NORMAL, 51, 1, 6, {}, 12, 1, 7, 821, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols0.dat"}},
  {{{std::nullopt, {0, 4314}, 7, cyclic_prefix::NORMAL, 51, 1, 32, {}, 13, 1, 3, 256, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols1.dat"}},
  {{{std::nullopt, {0, 4724}, 7, cyclic_prefix::NORMAL, 51, 1, 35, {}, 10, 1, 3, 5, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols2.dat"}},
  {{{std::nullopt, {0, 7750}, 0, cyclic_prefix::NORMAL, 51, 1, 16, {}, 3, 1, 8, 214, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols3.dat"}},
  {{{std::nullopt, {0, 3852}, 1, cyclic_prefix::NORMAL, 51, 1, 24, {}, 1, 1, 9, 946, 1, true, {0,}}, {0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols4.dat"}},
  {{{std::nullopt, {0, 1830}, 5, cyclic_prefix::NORMAL, 51, 1, 29, {}, 13, 1, 11, 435, 1, true, {0,1,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols5.dat"}},
  {{{std::nullopt, {0, 9684}, 7, cyclic_prefix::NORMAL, 51, 1, 37, {}, 10, 1, 8, 427, 1, true, {0,1,2,3,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols6.dat"}},
  {{{std::nullopt, {0, 752}, 1, cyclic_prefix::NORMAL, 51, 1, 47, {}, 13, 1, 5, 265, 1, true, {0,1,2,3,4,5,6,7,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols7.dat"}},
  {{{std::nullopt, {0, 7544}, 2, cyclic_prefix::NORMAL, 51, 1, 20, {}, 10, 1, 4, 103, 2, true, {0,}}, {1, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols8.dat"}},
  {{{std::nullopt, {0, 2826}, 8, cyclic_prefix::NORMAL, 51, 1, 3, {}, 2, 1, 3, 225, 2, true, {0,1,}}, {0, 1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols9.dat"}},
  {{{std::nullopt, {0, 4590}, 5, cyclic_prefix::NORMAL, 51, 1, 15, {}, 12, 1, 5, 820, 2, true, {0,1,2,3,}}, {0, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols10.dat"}},
  {{{std::nullopt, {0, 9138}, 4, cyclic_prefix::NORMAL, 51, 1, 6, {}, 7, 1, 0, 288, 2, true, {0,1,2,3,4,5,6,7,}}, {0, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols11.dat"}},
  {{{std::nullopt, {0, 8798}, 4, cyclic_prefix::NORMAL, 51, 1, 9, {}, 2, 1, 3, 139, 1, false, {0,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols12.dat"}},
  {{{std::nullopt, {0, 3686}, 8, cyclic_prefix::NORMAL, 51, 1, 6, {}, 13, 1, 3, 15, 1, false, {0,1,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols13.dat"}},
  {{{std::nullopt, {0, 962}, 1, cyclic_prefix::NORMAL, 51, 1, 1, {}, 13, 1, 5, 334, 1, false, {0,1,2,3,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols14.dat"}},
  {{{std::nullopt, {0, 8248}, 9, cyclic_prefix::NORMAL, 51, 1, 22, {}, 2, 1, 2, 495, 1, false, {0,1,2,3,4,5,6,7,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols15.dat"}},
  {{{std::nullopt, {0, 8092}, 6, cyclic_prefix::NORMAL, 51, 1, 44, {}, 6, 1, 3, 303, 2, false, {0,}}, {0, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols16.dat"}},
  {{{std::nullopt, {0, 8974}, 2, cyclic_prefix::NORMAL, 51, 1, 48, {}, 5, 1, 0, 384, 2, false, {0,1,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols17.dat"}},
  {{{std::nullopt, {0, 9828}, 9, cyclic_prefix::NORMAL, 51, 1, 35, {}, 5, 1, 10, 181, 2, false, {0,1,2,3,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols18.dat"}},
  {{{std::nullopt, {0, 8988}, 4, cyclic_prefix::NORMAL, 51, 1, 3, {}, 3, 1, 4, 980, 2, false, {0,1,2,3,4,5,6,7,}}, {0, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols19.dat"}},
  {{{std::nullopt, {0, 5916}, 3, cyclic_prefix::NORMAL, 51, 1, 13, {}, 2, 2, 9, 543, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols20.dat"}},
  {{{std::nullopt, {0, 9742}, 1, cyclic_prefix::NORMAL, 51, 1, 13, {}, 9, 2, 7, 791, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols21.dat"}},
  {{{std::nullopt, {0, 2432}, 1, cyclic_prefix::NORMAL, 51, 1, 38, {}, 6, 2, 4, 208, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols22.dat"}},
  {{{std::nullopt, {0, 7932}, 6, cyclic_prefix::NORMAL, 51, 1, 47, {}, 10, 2, 9, 459, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols23.dat"}},
  {{{std::nullopt, {0, 6382}, 1, cyclic_prefix::NORMAL, 51, 1, 42, {}, 4, 2, 6, 513, 1, true, {0,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols24.dat"}},
  {{{std::nullopt, {0, 5648}, 9, cyclic_prefix::NORMAL, 51, 1, 26, {}, 8, 2, 5, 611, 1, true, {0,1,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols25.dat"}},
  {{{std::nullopt, {0, 7040}, 5, cyclic_prefix::NORMAL, 51, 1, 10, {}, 0, 2, 1, 192, 1, true, {0,1,2,3,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols26.dat"}},
  {{{std::nullopt, {0, 6172}, 6, cyclic_prefix::NORMAL, 51, 1, 5, {}, 6, 2, 6, 54, 1, true, {0,1,2,3,4,5,6,7,}}, {0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols27.dat"}},
  {{{std::nullopt, {0, 3980}, 0, cyclic_prefix::NORMAL, 51, 1, 19, {}, 0, 2, 8, 217, 2, true, {0,}}, {0, 1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols28.dat"}},
  {{{std::nullopt, {0, 856}, 8, cyclic_prefix::NORMAL, 51, 1, 8, {}, 11, 2, 2, 267, 2, true, {0,1,}}, {1, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols29.dat"}},
  {{{std::nullopt, {0, 2410}, 0, cyclic_prefix::NORMAL, 51, 1, 39, {}, 8, 2, 0, 81, 2, true, {0,1,2,3,}}, {1, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols30.dat"}},
  {{{std::nullopt, {0, 6392}, 6, cyclic_prefix::NORMAL, 51, 1, 30, {}, 8, 2, 11, 133, 2, true, {0,1,2,3,4,5,6,7,}}, {0, 1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols31.dat"}},
  {{{std::nullopt, {0, 6894}, 7, cyclic_prefix::NORMAL, 51, 1, 1, {}, 10, 2, 3, 637, 1, false, {0,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols32.dat"}},
  {{{std::nullopt, {0, 8068}, 9, cyclic_prefix::NORMAL, 51, 1, 40, {}, 12, 2, 8, 139, 1, false, {0,1,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols33.dat"}},
  {{{std::nullopt, {0, 680}, 5, cyclic_prefix::NORMAL, 51, 1, 12, {}, 0, 2, 5, 446, 1, false, {0,1,2,3,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols34.dat"}},
  {{{std::nullopt, {0, 9198}, 4, cyclic_prefix::NORMAL, 51, 1, 11, {}, 4, 2, 10, 973, 1, false, {0,1,2,3,4,5,6,7,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols35.dat"}},
  {{{std::nullopt, {0, 4156}, 8, cyclic_prefix::NORMAL, 51, 1, 37, {}, 10, 2, 1, 717, 2, false, {0,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols36.dat"}},
  {{{std::nullopt, {0, 7950}, 0, cyclic_prefix::NORMAL, 51, 1, 36, {}, 3, 2, 5, 84, 2, false, {0,1,}}, {0, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols37.dat"}},
  {{{std::nullopt, {0, 686}, 3, cyclic_prefix::NORMAL, 51, 1, 46, {}, 4, 2, 0, 399, 2, false, {0,1,2,3,}}, {1, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols38.dat"}},
  {{{std::nullopt, {0, 8618}, 4, cyclic_prefix::NORMAL, 51, 1, 40, {}, 3, 2, 8, 475, 2, false, {0,1,2,3,4,5,6,7,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols39.dat"}},
  {{{std::nullopt, {0, 1358}, 4, cyclic_prefix::NORMAL, 51, 1, 10, {18}, 10, 2, 11, 999, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols40.dat"}},
  {{{std::nullopt, {0, 5526}, 8, cyclic_prefix::NORMAL, 51, 1, 43, {48}, 7, 2, 10, 452, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols41.dat"}},
  {{{std::nullopt, {0, 9524}, 2, cyclic_prefix::NORMAL, 51, 1, 30, {3}, 2, 2, 5, 809, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols42.dat"}},
  {{{std::nullopt, {0, 4796}, 8, cyclic_prefix::NORMAL, 51, 1, 9, {28}, 11, 2, 6, 828, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols43.dat"}},
  {{{std::nullopt, {0, 4956}, 8, cyclic_prefix::NORMAL, 51, 1, 2, {12}, 8, 2, 7, 887, 1, true, {0,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols44.dat"}},
  {{{std::nullopt, {0, 3298}, 4, cyclic_prefix::NORMAL, 51, 1, 5, {26}, 0, 2, 0, 276, 1, true, {0,1,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols45.dat"}},
  {{{std::nullopt, {0, 8564}, 7, cyclic_prefix::NORMAL, 51, 1, 3, {7}, 9, 2, 9, 831, 1, true, {0,1,2,3,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols46.dat"}},
  {{{std::nullopt, {0, 2070}, 0, cyclic_prefix::NORMAL, 51, 1, 21, {37}, 12, 2, 1, 293, 1, true, {0,1,2,3,4,5,6,7,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols47.dat"}},
  {{{std::nullopt, {0, 9396}, 3, cyclic_prefix::NORMAL, 51, 1, 38, {1}, 4, 2, 11, 552, 2, true, {0,}}, {1, 1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols48.dat"}},
  {{{std::nullopt, {0, 3334}, 7, cyclic_prefix::NORMAL, 51, 1, 0, {1}, 6, 2, 9, 410, 2, true, {0,1,}}, {0, 1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols49.dat"}},
  {{{std::nullopt, {0, 5822}, 1, cyclic_prefix::NORMAL, 51, 1, 40, {38}, 4, 2, 4, 241, 2, true, {0,1,2,3,}}, {0, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols50.dat"}},
  {{{std::nullopt, {0, 7012}, 1, cyclic_prefix::NORMAL, 51, 1, 48, {19}, 2, 2, 4, 286, 2, true, {0,1,2,3,4,5,6,7,}}, {1, 1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols51.dat"}},
  {{{std::nullopt, {0, 9234}, 2, cyclic_prefix::NORMAL, 51, 1, 49, {5}, 7, 2, 6, 218, 1, false, {0,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols52.dat"}},
  {{{std::nullopt, {0, 3724}, 7, cyclic_prefix::NORMAL, 51, 1, 32, {36}, 4, 2, 8, 86, 1, false, {0,1,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols53.dat"}},
  {{{std::nullopt, {0, 994}, 7, cyclic_prefix::NORMAL, 51, 1, 45, {44}, 4, 2, 11, 47, 1, false, {0,1,2,3,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols54.dat"}},
  {{{std::nullopt, {0, 248}, 4, cyclic_prefix::NORMAL, 51, 1, 44, {36}, 11, 2, 5, 873, 1, false, {0,1,2,3,4,5,6,7,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols55.dat"}},
  {{{std::nullopt, {0, 10146}, 8, cyclic_prefix::NORMAL, 51, 1, 0, {35}, 3, 2, 1, 59, 2, false, {0,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols56.dat"}},
  {{{std::nullopt, {0, 5574}, 7, cyclic_prefix::NORMAL, 51, 1, 1, {28}, 3, 2, 3, 981, 2, false, {0,1,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols57.dat"}},
  {{{std::nullopt, {0, 7554}, 2, cyclic_prefix::NORMAL, 51, 1, 37, {12}, 11, 2, 6, 785, 2, false, {0,1,2,3,}}, {1, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols58.dat"}},
  {{{std::nullopt, {0, 1354}, 2, cyclic_prefix::NORMAL, 51, 1, 36, {19}, 0, 2, 9, 742, 2, false, {0,1,2,3,4,5,6,7,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols59.dat"}},
  {{{std::nullopt, {1, 20235}, 1, cyclic_prefix::NORMAL, 51, 1, 35, {}, 5, 1, 0, 120, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols60.dat"}},
  {{{std::nullopt, {1, 7018}, 9, cyclic_prefix::NORMAL, 51, 1, 1, {}, 2, 1, 8, 788, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols61.dat"}},
  {{{std::nullopt, {1, 3841}, 4, cyclic_prefix::NORMAL, 51, 1, 10, {}, 11, 1, 0, 338, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols62.dat"}},
  {{{std::nullopt, {1, 7816}, 8, cyclic_prefix::NORMAL, 51, 1, 40, {}, 0, 1, 7, 6, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols63.dat"}},
  {{{std::nullopt, {1, 13799}, 3, cyclic_prefix::NORMAL, 51, 1, 35, {}, 8, 1, 9, 675, 1, true, {0,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols64.dat"}},
  {{{std::nullopt, {1, 17333}, 0, cyclic_prefix::NORMAL, 51, 1, 28, {}, 8, 1, 5, 198, 1, true, {0,1,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols65.dat"}},
  {{{std::nullopt, {1, 1388}, 4, cyclic_prefix::NORMAL, 51, 1, 10, {}, 5, 1, 5, 862, 1, true, {0,1,2,3,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols66.dat"}},
  {{{std::nullopt, {1, 11024}, 12, cyclic_prefix::NORMAL, 51, 1, 25, {}, 8, 1, 10, 909, 1, true, {0,1,2,3,4,5,6,7,}}, {0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols67.dat"}},
  {{{std::nullopt, {1, 3224}, 12, cyclic_prefix::NORMAL, 51, 1, 33, {}, 12, 1, 10, 693, 2, true, {0,}}, {0, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols68.dat"}},
  {{{std::nullopt, {1, 2323}, 5, cyclic_prefix::NORMAL, 51, 1, 13, {}, 12, 1, 3, 398, 2, true, {0,1,}}, {1, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols69.dat"}},
  {{{std::nullopt, {1, 3680}, 0, cyclic_prefix::NORMAL, 51, 1, 41, {}, 11, 1, 10, 453, 2, true, {0,1,2,3,}}, {0, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols70.dat"}},
  {{{std::nullopt, {1, 12392}, 6, cyclic_prefix::NORMAL, 51, 1, 32, {}, 7, 1, 4, 220, 2, true, {0,1,2,3,4,5,6,7,}}, {0, 1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols71.dat"}},
  {{{std::nullopt, {1, 4166}, 3, cyclic_prefix::NORMAL, 51, 1, 7, {}, 7, 1, 0, 158, 1, false, {0,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols72.dat"}},
  {{{std::nullopt, {1, 9261}, 4, cyclic_prefix::NORMAL, 51, 1, 30, {}, 12, 1, 3, 196, 1, false, {0,1,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols73.dat"}},
  {{{std::nullopt, {1, 11770}, 5, cyclic_prefix::NORMAL, 51, 1, 22, {}, 8, 1, 7, 640, 1, false, {0,1,2,3,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols74.dat"}},
  {{{std::nullopt, {1, 18936}, 8, cyclic_prefix::NORMAL, 51, 1, 26, {}, 1, 1, 0, 140, 1, false, {0,1,2,3,4,5,6,7,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols75.dat"}},
  {{{std::nullopt, {1, 6921}, 4, cyclic_prefix::NORMAL, 51, 1, 1, {}, 7, 1, 3, 14, 2, false, {0,}}, {0, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols76.dat"}},
  {{{std::nullopt, {1, 15320}, 0, cyclic_prefix::NORMAL, 51, 1, 44, {}, 3, 1, 4, 318, 2, false, {0,1,}}, {1, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols77.dat"}},
  {{{std::nullopt, {1, 1582}, 1, cyclic_prefix::NORMAL, 51, 1, 25, {}, 9, 1, 3, 785, 2, false, {0,1,2,3,}}, {1, 1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols78.dat"}},
  {{{std::nullopt, {1, 16499}, 3, cyclic_prefix::NORMAL, 51, 1, 46, {}, 13, 1, 11, 445, 2, false, {0,1,2,3,4,5,6,7,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols79.dat"}},
  {{{std::nullopt, {1, 15599}, 3, cyclic_prefix::NORMAL, 51, 1, 0, {}, 12, 2, 6, 94, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols80.dat"}},
  {{{std::nullopt, {1, 13978}, 9, cyclic_prefix::NORMAL, 51, 1, 50, {}, 5, 2, 11, 895, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols81.dat"}},
  {{{std::nullopt, {1, 10144}, 12, cyclic_prefix::NORMAL, 51, 1, 18, {}, 10, 2, 10, 196, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols82.dat"}},
  {{{std::nullopt, {1, 4282}, 11, cyclic_prefix::NORMAL, 51, 1, 17, {}, 9, 2, 10, 939, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols83.dat"}},
  {{{std::nullopt, {1, 19205}, 6, cyclic_prefix::NORMAL, 51, 1, 18, {}, 11, 2, 1, 543, 1, true, {0,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols84.dat"}},
  {{{std::nullopt, {1, 12045}, 6, cyclic_prefix::NORMAL, 51, 1, 18, {}, 1, 2, 0, 799, 1, true, {0,1,}}, {0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols85.dat"}},
  {{{std::nullopt, {1, 4953}, 0, cyclic_prefix::NORMAL, 51, 1, 12, {}, 2, 2, 11, 6, 1, true, {0,1,2,3,}}, {0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols86.dat"}},
  {{{std::nullopt, {1, 4501}, 4, cyclic_prefix::NORMAL, 51, 1, 32, {}, 0, 2, 2, 214, 1, true, {0,1,2,3,4,5,6,7,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols87.dat"}},
  {{{std::nullopt, {1, 5242}, 1, cyclic_prefix::NORMAL, 51, 1, 3, {}, 5, 2, 0, 987, 2, true, {0,}}, {1, 1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols88.dat"}},
  {{{std::nullopt, {1, 17501}, 4, cyclic_prefix::NORMAL, 51, 1, 1, {}, 0, 2, 5, 848, 2, true, {0,1,}}, {0, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols89.dat"}},
  {{{std::nullopt, {1, 12719}, 3, cyclic_prefix::NORMAL, 51, 1, 34, {}, 4, 2, 7, 125, 2, true, {0,1,2,3,}}, {1, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols90.dat"}},
  {{{std::nullopt, {1, 19256}, 8, cyclic_prefix::NORMAL, 51, 1, 14, {}, 8, 2, 7, 786, 2, true, {0,1,2,3,4,5,6,7,}}, {0, 0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols91.dat"}},
  {{{std::nullopt, {1, 12182}, 11, cyclic_prefix::NORMAL, 51, 1, 33, {}, 4, 2, 11, 631, 1, false, {0,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols92.dat"}},
  {{{std::nullopt, {1, 7303}, 5, cyclic_prefix::NORMAL, 51, 1, 46, {}, 6, 2, 5, 216, 1, false, {0,1,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols93.dat"}},
  {{{std::nullopt, {1, 12542}, 11, cyclic_prefix::NORMAL, 51, 1, 26, {}, 3, 2, 7, 477, 1, false, {0,1,2,3,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols94.dat"}},
  {{{std::nullopt, {1, 4448}, 4, cyclic_prefix::NORMAL, 51, 1, 47, {}, 5, 2, 6, 143, 1, false, {0,1,2,3,4,5,6,7,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols95.dat"}},
  {{{std::nullopt, {1, 1781}, 4, cyclic_prefix::NORMAL, 51, 1, 21, {}, 6, 2, 7, 873, 2, false, {0,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols96.dat"}},
  {{{std::nullopt, {1, 12304}, 12, cyclic_prefix::NORMAL, 51, 1, 14, {}, 0, 2, 5, 216, 2, false, {0,1,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols97.dat"}},
  {{{std::nullopt, {1, 7180}, 0, cyclic_prefix::NORMAL, 51, 1, 3, {}, 4, 2, 3, 258, 2, false, {0,1,2,3,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols98.dat"}},
  {{{std::nullopt, {1, 2399}, 3, cyclic_prefix::NORMAL, 51, 1, 21, {}, 4, 2, 11, 531, 2, false, {0,1,2,3,4,5,6,7,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols99.dat"}},
  {{{std::nullopt, {1, 5852}, 6, cyclic_prefix::NORMAL, 51, 1, 6, {31}, 6, 2, 5, 74, 0, true, {0,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols100.dat"}},
  {{{std::nullopt, {1, 1886}, 3, cyclic_prefix::NORMAL, 51, 1, 45, {1}, 0, 2, 4, 401, 0, true, {0,1,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols101.dat"}},
  {{{std::nullopt, {1, 6450}, 5, cyclic_prefix::NORMAL, 51, 1, 7, {2}, 0, 2, 11, 696, 0, true, {0,1,2,3,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols102.dat"}},
  {{{std::nullopt, {1, 11852}, 6, cyclic_prefix::NORMAL, 51, 1, 27, {20}, 7, 2, 11, 44, 0, true, {0,1,2,3,4,5,6,7,}}, {}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols103.dat"}},
  {{{std::nullopt, {1, 942}, 11, cyclic_prefix::NORMAL, 51, 1, 35, {20}, 10, 2, 4, 342, 1, true, {0,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols104.dat"}},
  {{{std::nullopt, {1, 13246}, 3, cyclic_prefix::NORMAL, 51, 1, 5, {11}, 4, 2, 3, 995, 1, true, {0,1,}}, {1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols105.dat"}},
  {{{std::nullopt, {1, 4026}, 3, cyclic_prefix::NORMAL, 51, 1, 29, {46}, 10, 2, 2, 309, 1, true, {0,1,2,3,}}, {1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols106.dat"}},
  {{{std::nullopt, {1, 7615}, 1, cyclic_prefix::NORMAL, 51, 1, 15, {31}, 2, 2, 5, 770, 1, true, {0,1,2,3,4,5,6,7,}}, {0}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols107.dat"}},
  {{{std::nullopt, {1, 4999}, 3, cyclic_prefix::NORMAL, 51, 1, 40, {17}, 12, 2, 5, 308, 2, true, {0,}}, {1, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols108.dat"}},
  {{{std::nullopt, {1, 10582}, 11, cyclic_prefix::NORMAL, 51, 1, 8, {0}, 1, 2, 6, 746, 2, true, {0,1,}}, {1, 1}, {1}}, {"test_data/pucch_processor_format0_test_input_symbols109.dat"}},
  {{{std::nullopt, {1, 8864}, 12, cyclic_prefix::NORMAL, 51, 1, 28, {8}, 3, 2, 2, 860, 2, true, {0,1,2,3,}}, {1, 0}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols110.dat"}},
  {{{std::nullopt, {1, 13640}, 0, cyclic_prefix::NORMAL, 51, 1, 24, {42}, 11, 2, 3, 620, 2, true, {0,1,2,3,4,5,6,7,}}, {0, 1}, {0}}, {"test_data/pucch_processor_format0_test_input_symbols111.dat"}},
  {{{std::nullopt, {1, 18625}, 6, cyclic_prefix::NORMAL, 51, 1, 48, {17}, 0, 2, 4, 48, 1, false, {0,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols112.dat"}},
  {{{std::nullopt, {1, 19855}, 1, cyclic_prefix::NORMAL, 51, 1, 31, {28}, 3, 2, 0, 761, 1, false, {0,1,}}, {1}, {}}, {"test_data/pucch_processor_format0_test_input_symbols113.dat"}},
  {{{std::nullopt, {1, 14581}, 4, cyclic_prefix::NORMAL, 51, 1, 6, {40}, 12, 2, 11, 924, 1, false, {0,1,2,3,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols114.dat"}},
  {{{std::nullopt, {1, 6104}, 12, cyclic_prefix::NORMAL, 51, 1, 43, {23}, 10, 2, 3, 172, 1, false, {0,1,2,3,4,5,6,7,}}, {0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols115.dat"}},
  {{{std::nullopt, {1, 6620}, 10, cyclic_prefix::NORMAL, 51, 1, 18, {38}, 6, 2, 0, 826, 2, false, {0,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols116.dat"}},
  {{{std::nullopt, {1, 3816}, 8, cyclic_prefix::NORMAL, 51, 1, 45, {19}, 0, 2, 10, 315, 2, false, {0,1,}}, {1, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols117.dat"}},
  {{{std::nullopt, {1, 5660}, 0, cyclic_prefix::NORMAL, 51, 1, 7, {13}, 10, 2, 8, 994, 2, false, {0,1,2,3,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols118.dat"}},
  {{{std::nullopt, {1, 4759}, 3, cyclic_prefix::NORMAL, 51, 1, 44, {50}, 10, 2, 0, 580, 2, false, {0,1,2,3,4,5,6,7,}}, {0, 0}, {}}, {"test_data/pucch_processor_format0_test_input_symbols119.dat"}},
    // clang-format on
};

} // namespace ocudu
