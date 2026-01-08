%ocuduPDSCHDMRS Physical downlink shared channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPDSCHDMRS(CARRIER, PDSCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPDSCHConfig, nrPDSCHDMRSConfig, nrPDSCHDMRS and nrPDSCHDMRSIndices.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [DMRSsymbols, symbolIndices] = ocuduPDSCHDMRS(carrier, pdsch)

    DMRSsymbols = nrPDSCHDMRS(carrier, pdsch);
    symbolIndices = nrPDSCHDMRSIndices(carrier, pdsch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
