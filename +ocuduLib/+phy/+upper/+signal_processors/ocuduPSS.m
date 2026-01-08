%ocuduPSS Primary synchronization signal.
%   [PSSSYMBOLS, PSSINDICES] = ocuduPSS(NCELLID) generates the PSS for a
%   given physical cell ID NCELLID and returns the BPSK modulated symbols
%   PSSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPSS and nrPSSIndices.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [PSSsymbols, PSSindices] = ocuduPSS(NCellID)

    PSSsymbols = nrPSS(NCellID);
    PSSindices = nrPSSIndices('IndexStyle', 'subscript', 'IndexBase', '0based');

end
