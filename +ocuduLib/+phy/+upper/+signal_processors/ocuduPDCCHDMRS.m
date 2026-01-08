%ocuduPDCCHDMRS Physical control channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPDCCHDMRS(CARRIER, PDCCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPDCCHConfig and nrPDCCHSpace.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [DMRSsymbols, symbolIndices] = ocuduPDCCHDMRS(carrier, pdcch)

    % no need of keeping track of the resource element indices of the PDCCH
    [~,DMRSsymbols,symbolIndices] = nrPDCCHSpace(carrier, pdcch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
