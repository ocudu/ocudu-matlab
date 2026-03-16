%ocuduCSIRSNZP Non-Zero-Power Channel-State Information Reference Signals.
%   [CSIRSSYMBOLS, SYMBOLINDICES] = ocuduCSIRSNZP(CARRIER, CSIRS, AMPLITUDE)
%   generates the NZP-CSI-RS sequence and stores it in CSIRSSYMBOLS. The
%   mapping indices are generated and stored in SYMBOLINDICES.
%
%   See also nrCarrierConfig, nrCSIRSConfig, nrCSIRS and nrCSIRSIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [CSIRSsymbols, symbolIndices] = ocuduCSIRSNZP(carrier, csirs, amplitude)

    CSIRSsymbols = nrCSIRS(carrier, csirs);
    CSIRSsymbols = CSIRSsymbols * amplitude;
    symbolIndices = nrCSIRSIndices(carrier, csirs, 'IndexStyle', 'subscript', 'IndexBase', '0based');

