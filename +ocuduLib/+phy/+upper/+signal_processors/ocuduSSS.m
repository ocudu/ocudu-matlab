%ocuduSSS Secondary synchronization signal.
%   [SSSSYMBOLS, SSSINDICES] = ocuduSSS(NCELLID) generates the SSS for a
%   given physical cell ID NCELLID and returns the BPSK modulated symbols
%   SSSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrSSS and nrSSSIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [SSSsymbols, SSSindices] = ocuduSSS(NCellID)

    SSSsymbols = nrSSS(NCellID);
    SSSindices = nrSSSIndices('IndexStyle', 'subscript', 'IndexBase', '0based');

end
