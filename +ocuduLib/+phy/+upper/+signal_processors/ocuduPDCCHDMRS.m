%ocuduPDCCHDMRS Physical control channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPDCCHDMRS(CARRIER, PDCCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPDCCHConfig and nrPDCCHSpace.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [DMRSsymbols, symbolIndices] = ocuduPDCCHDMRS(carrier, pdcch)

    % no need of keeping track of the resource element indices of the PDCCH
    [~,DMRSsymbols,symbolIndices] = nrPDCCHSpace(carrier, pdcch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
