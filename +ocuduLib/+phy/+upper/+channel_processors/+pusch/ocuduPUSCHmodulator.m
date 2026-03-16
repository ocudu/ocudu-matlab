%ocuduPUSCHmodulator Physical Uplink Shared Channel.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPUSCHmodulator(CARRIER, PUSCH, CW)
%   modulates a single PUSCH codeword CW and returns the complex symbols
%   MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPUSCH, nrPUSCHIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [modulatedSymbols, symbolIndices] = ocuduPUSCHmodulator(carrier, pusch, cw)
    modulatedSymbols = nrPUSCH(carrier, pusch, cw);

    symbolIndices = nrPUSCHIndices(carrier, pusch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
