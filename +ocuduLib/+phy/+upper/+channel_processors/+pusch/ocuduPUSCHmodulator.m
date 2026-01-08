%ocuduPUSCHmodulator Physical Uplink Shared Channel.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPUSCHmodulator(CARRIER, PUSCH, CW)
%   modulates a single PUSCH codeword CW and returns the complex symbols
%   MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPUSCH, nrPUSCHIndices.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [modulatedSymbols, symbolIndices] = ocuduPUSCHmodulator(carrier, pusch, cw)
    modulatedSymbols = nrPUSCH(carrier, pusch, cw);

    symbolIndices = nrPUSCHIndices(carrier, pusch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
