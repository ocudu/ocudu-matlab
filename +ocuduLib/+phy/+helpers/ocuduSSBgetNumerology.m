%ocuduSSBgetNumerology Returns the numerology of a given SSB pattern.
%   NUMEROLOGY = ocuduSSBgetNumerology(SSBPATTERN) returns a subcarrier space NUMEROLOGY
%   given an SSB pattern SSBPATTERN.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

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
