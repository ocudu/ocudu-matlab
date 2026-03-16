%ocuduSSS Secondary synchronization signal.
%   [SSSSYMBOLS, SSSINDICES] = ocuduSSS(NCELLID) generates the SSS for a
%   given physical cell ID NCELLID and returns the BPSK modulated symbols
%   SSSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrSSS and nrSSSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [SSSsymbols, SSSindices] = ocuduSSS(NCellID)

    SSSsymbols = nrSSS(NCellID);
    SSSindices = nrSSSIndices('IndexStyle', 'subscript', 'IndexBase', '0based');

end
