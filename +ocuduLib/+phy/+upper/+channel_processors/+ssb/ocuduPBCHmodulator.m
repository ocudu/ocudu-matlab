%ocuduPBCHmodulator Physical broadcast channel.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPBCHmodulator(CW, NCELLID, LMAX)
%   modulates the 864-bit BCH codeword CW and returns the complex symbols
%   MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPBCH, nrPBCHIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [modulatedSymbols, symbolIndices] = ocuduPBCHmodulator(cw, NCellID, SSBindex, Lmax)

    % v as described in TS 38.211 Section 7.3.3.1
    if Lmax == 4
        v = mod(SSBindex, 4); % 2 LSBs of SSB index
    else
        v = mod(SSBindex, 8); % 3 LSBs of SSB index
    end
    modulatedSymbols = nrPBCH(cw, NCellID, v);
    symbolIndices = nrPBCHIndices(NCellID, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
