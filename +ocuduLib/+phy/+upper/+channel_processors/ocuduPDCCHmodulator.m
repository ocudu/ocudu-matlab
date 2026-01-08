%ocuduPDCCHmodulator Physical Downlink Control channel modulator.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPDCCHmodulator(CW, CARRIER, PDCCH, NID, RNTI)
%   modulates the codeword CW using CARRIER and PDCCH objects and returns 
%   the complex symbols MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPDCCH, nrPDCCHResources.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [modulatedSymbols, symbolIndices] = ocuduPDCCHmodulator(cw, carrier, pdcch, nID, rnti)
    % get modulated symbols and resource-element indices
    modulatedSymbols = nrPDCCH(cw, nID, rnti);
    symbolIndices = nrPDCCHResources(carrier, pdcch, ...
        'IndexStyle', 'subscript', 'IndexBase', '0based');
end
