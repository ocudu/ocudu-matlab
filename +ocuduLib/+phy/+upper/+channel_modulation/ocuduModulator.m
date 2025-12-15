%ocuduModulator Generation of modulated symbols from an input bit array.
%   MODULATEDSYMBOLS = ocuduModulator(CW, SCHEME)
%   modulates the input bit sequence accordig to the requested SCHEME
%   and returns the complex symbols MODULATEDSYMBOLS.
%
%   See also nrPBCHDMRS, nrPBCHDMRSIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function modulatedSymbols = ocuduModulator(cw, scheme)
    modulatedSymbols = nrSymbolModulate(cw, scheme, 'OutputDataType', 'single');
end
