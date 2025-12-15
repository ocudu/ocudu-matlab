%ocuduPUSCHDMRS Physical downlink shared channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPUSCHDMRS(CARRIER, PUSCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPUSCHConfig, nrPUSCHDMRSConfig, nrPUSCHDMRS and nrPUSCHDMRSIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [DMRSsymbols, symbolIndices] = ocuduPUSCHDMRS(carrier, pusch)

    DMRSsymbols = nrPUSCHDMRS(carrier, pusch);
    symbolIndices = nrPUSCHDMRSIndices(carrier, pusch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
