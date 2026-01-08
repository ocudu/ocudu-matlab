%ocuduPUCCHDMRS Physical uplink control channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPUCCHDMRS(CARRIER, PUCCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPUCCHDMRS and nrPUCCHDMRSIndices.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [DMRSsymbols, symbolIndices] = ocuduPUCCHDMRS(carrier, pucch)

    DMRSsymbols   = nrPUCCHDMRS(carrier, pucch);
    symbolIndices = nrPUCCHDMRSIndices(carrier, pucch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
