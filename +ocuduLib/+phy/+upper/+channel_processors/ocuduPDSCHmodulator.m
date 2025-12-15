%ocuduPDSCHmodulator Physical Downlink Shared Channel.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPDSCHmodulator(CARRIER, PDSCH, CWS)
%   modulates up to two PDSCH codewords CWS and returns the complex symbols
%   MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPDSCH, nrPDSCHIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [modulatedSymbols, symbolIndices] = ocuduPDSCHmodulator(carrier, pdsch, cws)
    modulatedSymbols = nrPDSCH(carrier, pdsch, cws);

    symbolIndices = nrPDSCHIndices(carrier, pdsch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
