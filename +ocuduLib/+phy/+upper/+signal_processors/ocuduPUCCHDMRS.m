%ocuduPUCCHDMRS Physical uplink control channel demodulation reference signals.
%   [DMRSSYMBOLS, SYMBOLINDICES] = ocuduPUCCHDMRS(CARRIER, PUCCH)
%   modulates the demodulation reference signals and returns the complex symbols
%   DMRSSYMBOLS as well as a column vector of RE indices.
%
%   See also nrPUCCHDMRS and nrPUCCHDMRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [DMRSsymbols, symbolIndices] = ocuduPUCCHDMRS(carrier, pucch)

    DMRSsymbols   = nrPUCCHDMRS(carrier, pucch);
    symbolIndices = nrPUCCHDMRSIndices(carrier, pucch, 'IndexStyle', 'subscript', 'IndexBase', '0based');

end
