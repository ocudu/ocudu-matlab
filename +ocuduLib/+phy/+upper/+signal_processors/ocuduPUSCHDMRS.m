%ocuduPUSCHDMRS Physical downlink shared channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPUSCHDMRS(CARRIER, PUSCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrCarrierConfig, nrPUSCHConfig, nrPUSCHDMRSConfig, nrPUSCHDMRS and nrPUSCHDMRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [DMRSsymbols, symbolIndices] = ocuduPUSCHDMRS(carrier, pusch)

    DMRSsymbols = nrPUSCHDMRS(carrier, pusch);
    symbolIndices = nrPUSCHDMRSIndices(carrier, pusch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
