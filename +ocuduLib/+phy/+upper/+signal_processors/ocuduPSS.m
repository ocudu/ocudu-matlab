%ocuduPSS Primary synchronization signal.
%   [PSSSYMBOLS, PSSINDICES] = ocuduPSS(NCELLID) generates the PSS for a
%   given physical cell ID NCELLID and returns the BPSK modulated symbols
%   PSSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPSS and nrPSSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [PSSsymbols, PSSindices] = ocuduPSS(NCellID)

    PSSsymbols = nrPSS(NCellID);
    PSSindices = nrPSSIndices('IndexStyle', 'subscript', 'IndexBase', '0based');

end
