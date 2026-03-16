%ocuduSSBgetFirstSymbolIndex Calculates the position of the first SS/PBCH subcarrier.
%   SSBFIRSTSUBCARRIERINDEX = ocuduSSBgetFirstSubcarrierIndex(NUMEROLOGY, POINTAOFFSET, SSBOFFSET)
%   returns a subcarrier index SSBFIRSTSUBCARRIERINDEX, given a subcarrier spacing NUMEROLOGY,
%   a bottom grid value POINTAOFFSET and an SSB offset SSBOFFSET. Note that
%   SSBFIRSTSUBCARRIERINDEX is relative to POINTAOFFSET.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function SSBfirstSubcarrierIndex = ocuduSSBgetFirstSubcarrierIndex(numerology, pointAoffset, SSBoffset)

  NRE = 12; % number of RE per RB
  SSBfirstSubcarrierIndex = pointAoffset * NRE + (SSBoffset / (2 .^ numerology));

end
