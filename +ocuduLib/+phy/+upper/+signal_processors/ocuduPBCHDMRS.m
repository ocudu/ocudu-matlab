%ocuduPBCHDMRS Physical broadcast channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPBCHDMRS(NCELLID, SSBINDEX, LMAX, NHF)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPBCHDMRS, nrPBCHDMRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

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
