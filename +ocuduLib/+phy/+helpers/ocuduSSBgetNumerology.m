%ocuduSSBgetNumerology Returns the numerology of a given SSB pattern.
%   NUMEROLOGY = ocuduSSBgetNumerology(SSBPATTERN) returns a subcarrier space NUMEROLOGY
%   given an SSB pattern SSBPATTERN.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function numerology = ocuduSSBgetNumerology(SSBpattern)

  numerology = 0; %default 15 kHz SCS
  switch SSBpattern
      case {'B', 'C'}
          numerology = 1; %30 kHz SCS
      case 'D'
          numerology = 3; %120 kHz SCS
      case 'E'
          numerology = 4; %240 kHz SCS
  end

end
