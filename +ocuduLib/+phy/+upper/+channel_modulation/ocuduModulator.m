%ocuduModulator Generation of modulated symbols from an input bit array.
%   MODULATEDSYMBOLS = ocuduModulator(CW, SCHEME)
%   modulates the input bit sequence accordig to the requested SCHEME
%   and returns the complex symbols MODULATEDSYMBOLS.
%
%   See also nrPBCHDMRS, nrPBCHDMRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function modulatedSymbols = ocuduModulator(cw, scheme)
    modulatedSymbols = nrSymbolModulate(cw, scheme, 'OutputDataType', 'single');
end
