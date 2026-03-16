%ocuduPDCCHmodulator Physical Downlink Control channel modulator.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPDCCHmodulator(CW, CARRIER, PDCCH, NID, RNTI)
%   modulates the codeword CW using CARRIER and PDCCH objects and returns 
%   the complex symbols MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPDCCH, nrPDCCHResources.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [modulatedSymbols, symbolIndices] = ocuduPDCCHmodulator(cw, carrier, pdcch, nID, rnti)
    % get modulated symbols and resource-element indices
    modulatedSymbols = nrPDCCH(cw, nID, rnti);
    symbolIndices = nrPDCCHResources(carrier, pdcch, ...
        'IndexStyle', 'subscript', 'IndexBase', '0based');
end
