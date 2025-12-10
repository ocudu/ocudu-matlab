%ocuduCSIRSNZP Non-Zero-Power Channel-State Information Reference Signals.
%   [CSIRSSYMBOLS, SYMBOLINDICES] = ocuduCSIRSNZP(CARRIER, CSIRS, AMPLITUDE)
%   generates the NZP-CSI-RS sequence and stores it in CSIRSSYMBOLS. The
%   mapping indices are generated and stored in SYMBOLINDICES.
%
%   See also nrCarrierConfig, nrCSIRSConfig, nrCSIRS and nrCSIRSIndices.

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

function [CSIRSsymbols, symbolIndices] = ocuduCSIRSNZP(carrier, csirs, amplitude)

    CSIRSsymbols = nrCSIRS(carrier, csirs);
    CSIRSsymbols = CSIRSsymbols * amplitude;
    symbolIndices = nrCSIRSIndices(carrier, csirs, 'IndexStyle', 'subscript', 'IndexBase', '0based');

