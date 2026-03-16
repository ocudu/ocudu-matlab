%ocuduPDSCHmodulator Physical Downlink Shared Channel.
%   [MODULATEDSYMBOLS, SYMBOLINDICES] = ocuduPDSCHmodulator(CARRIER, PDSCH, CWS)
%   modulates up to two PDSCH codewords CWS and returns the complex symbols
%   MODULATEDSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPDSCH, nrPDSCHIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [modulatedSymbols, symbolIndices] = ocuduPDSCHmodulator(carrier, pdsch, cws)
    modulatedSymbols = nrPDSCH(carrier, pdsch, cws);

    symbolIndices = nrPDSCHIndices(carrier, pdsch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
