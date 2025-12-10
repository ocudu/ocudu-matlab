/*
 *
 * Copyright 2021-2025 Software Radio Systems Limited
 *
 * This file is part of OCUDU-matlab.
 *
 * OCUDU-matlab is free software: you can redistribute it and/or
 * modify it under the terms of the BSD 2-Clause License.
 *
 * OCUDU-matlab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * BSD 2-Clause License for more details.
 *
 * A copy of the BSD 2-Clause License can be found in the LICENSE
 * file in the top-level directory of this distribution.
 *
 */

/// \file
/// \brief Helper functions to convert variables from MATLAB convention to OCUDU convention.

#pragma once

#include "ocudu/phy/upper/dmrs_mapping.h"
#include "ocudu/ran/cyclic_prefix.h"
#include "ocudu/ran/prach/prach_format_type.h"
#include "ocudu/ran/prach/restricted_set_config.h"
#include "ocudu/ran/sch/ldpc_base_graph.h"
#include "ocudu/ran/sch/modulation_scheme.h"
#include "ocudu/ran/subcarrier_spacing.h"
#include "ocudu/support/error_handling.h"
#include "ocudu/support/ocudu_assert.h"
#include <string>

namespace ocudu_matlab {
/// \brief Converts modulation names from MATLAB convention to OCUDU convention.
/// \param[in] modulation_name   A string identifying a NR modulation according to MATLAB convention.
/// \return A modulation identifier according to OCUDU convention.
inline ocudu::modulation_scheme matlab_to_ocudu_modulation(const std::string& modulation_name)
{
  if (modulation_name == "BPSK") {
    return ocudu::modulation_scheme::BPSK;
  }
  if (modulation_name == "pi/2-BPSK") {
    return ocudu::modulation_scheme::PI_2_BPSK;
  }
  if (modulation_name == "QPSK") {
    return ocudu::modulation_scheme::QPSK;
  }
  if ((modulation_name == "QAM16") || (modulation_name == "16QAM")) {
    return ocudu::modulation_scheme::QAM16;
  }
  if ((modulation_name == "QAM64") || (modulation_name == "64QAM")) {
    return ocudu::modulation_scheme::QAM64;
  }
  if ((modulation_name == "QAM256") || (modulation_name == "256QAM")) {
    return ocudu::modulation_scheme::QAM256;
  }
  ocudu::ocudu_terminate("Unknown modulation {}.", modulation_name);
}

/// \brief Converts a MATLAB base graph index to an OCUDU base graph identifier.
/// \param[in] bg  An LDPC base graph index in {1, 2}.
/// \return An LDPC base graph identifier according to OCUDU convention.
inline ocudu::ldpc_base_graph_type matlab_to_ocudu_base_graph(unsigned bg)
{
  if (bg == 1) {
    return ocudu::ldpc_base_graph_type::BG1;
  }
  if (bg == 2) {
    return ocudu::ldpc_base_graph_type::BG2;
  }
  ocudu::ocudu_terminate("Unknown base graph {}.", bg);
}

/// \brief Converts a MATLAB PRACH restricted set type to an OCUDU PRACH restricted set identifier.
/// \param[in] restricted_set  A string identifying a NR PRACH restricted set type according to MATLAB convention.
/// \return A PRACH restricted set identifier according to OCUDU convention.
inline ocudu::restricted_set_config matlab_to_ocudu_restricted_set(const std::string& restricted_set)
{
  if (restricted_set == "UnrestrictedSet") {
    return ocudu::restricted_set_config::UNRESTRICTED;
  }
  if (restricted_set == "RestrictedSetTypeA") {
    return ocudu::restricted_set_config::TYPE_A;
  }
  if (restricted_set == "RestrictedSetTypeB") {
    return ocudu::restricted_set_config::TYPE_B;
  }
  ocudu::ocudu_terminate("Unknown restricted set {}.", restricted_set);
}

/// \brief Converts a MATLAB PRACH preamble format identifier to an OCUDU PRACH preamble identifier.
/// \param[in] preamble_format  A string identifying a NR PRACH preamble format according to MATLAB convention.
/// \return A PRACH preamble format according to OCUDU convention.
inline ocudu::prach_format_type matlab_to_ocudu_preamble_format(const std::string& preamble_format)
{
  return ocudu::to_prach_format_type(preamble_format.c_str());
}

/// \brief Converts a MATLAB DM-RS type to an OCUDU DM-RS type.
/// \param[in] type A DM-RS type in {1, 2}.
/// \return A DM-RS type identifier according to OCUDU convention.
inline ocudu::dmrs_type matlab_to_ocudu_dmrs_type(unsigned type)
{
  if (type == 1) {
    return ocudu::dmrs_type::TYPE1;
  }
  if (type == 2) {
    return ocudu::dmrs_type::TYPE2;
  }
  ocudu::ocudu_terminate("Unknown DMRS type {}.", type);
}

/// \brief Converts a MATLAB cyclic prefix string into an OCUDU cyclic prefix.
/// \param[in] cp A cyclic prefix string in <tt>{"normal", "extended"}</tt>.
/// \return A cyclic prefix identifier according to OCUDU convention.
inline ocudu::cyclic_prefix matlab_to_ocudu_cyclic_prefix(const std::string& cp)
{
  if (cp == "normal") {
    return ocudu::cyclic_prefix::NORMAL;
  }
  if (cp == "extended") {
    return ocudu::cyclic_prefix::EXTENDED;
  }
  ocudu::ocudu_terminate("Unknown cyclic prefix {}.", cp);
}

/// \brief Converts a subcarrier spacing value to an OCUDU subcarrier spacing.
/// \param[in] scs_kHz The subcarrier spacing value in kHz.
/// \return A subcarrier spacing according to OCUDU convention.
inline ocudu::subcarrier_spacing matlab_to_ocudu_subcarrier_spacing(unsigned scs_kHz)
{
  if (scs_kHz == 15) {
    return ocudu::subcarrier_spacing::kHz15;
  }
  if (scs_kHz == 30) {
    return ocudu::subcarrier_spacing::kHz30;
  }
  if (scs_kHz == 60) {
    return ocudu::subcarrier_spacing::kHz60;
  }
  if (scs_kHz == 120) {
    return ocudu::subcarrier_spacing::kHz120;
  }
  if (scs_kHz == 240) {
    return ocudu::subcarrier_spacing::kHz240;
  }
  ocudu::ocudu_terminate("Unknown subcarrier spacing {} kHz.", scs_kHz);
}

} // namespace ocudu_matlab
