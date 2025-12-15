%ocuduPBCHDMRS Physical broadcast channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPBCHDMRS(NCELLID, SSBINDEX, LMAX, NHF)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPBCHDMRS, nrPBCHDMRSIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [DMRSsymbols, symbolIndices] = ocuduPBCHDMRS(NCellID, SSBindex, Lmax, nHF)

    % iBar as described in TS 38.211 Section 7.4.1.4.1
    if Lmax == 4
        iBar = mod(SSBindex, 4) + 4 * nHF; % i = 2 LSBs of SSB index
    else
        iBar = mod(SSBindex, 8);           % i = 3 LSBs of SSB index
    end
    DMRSsymbols = nrPBCHDMRS(NCellID,iBar);
    symbolIndices = nrPBCHDMRSIndices(NCellID, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
