%ocuduPSS Primary synchronization signal.
%   [PSSSYMBOLS, PSSINDICES] = ocuduPSS(NCELLID) generates the PSS for a
%   given physical cell ID NCELLID and returns the BPSK modulated symbols
%   PSSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPSS and nrPSSIndices.

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

function [PSSsymbols, PSSindices] = ocuduPSS(NCellID)

    PSSsymbols = nrPSS(NCellID);
    PSSindices = nrPSSIndices('IndexStyle', 'subscript', 'IndexBase', '0based');

end
