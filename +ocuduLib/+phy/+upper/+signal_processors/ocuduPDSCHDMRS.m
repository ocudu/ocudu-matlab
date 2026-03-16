%ocuduPDSCHDMRS Physical downlink shared channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPDSCHDMRS(CARRIER, PDSCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPDSCHConfig, nrPDSCHDMRSConfig, nrPDSCHDMRS and nrPDSCHDMRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [DMRSsymbols, symbolIndices] = ocuduPDSCHDMRS(carrier, pdsch)

    DMRSsymbols = nrPDSCHDMRS(carrier, pdsch);
    symbolIndices = nrPDSCHDMRSIndices(carrier, pdsch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
