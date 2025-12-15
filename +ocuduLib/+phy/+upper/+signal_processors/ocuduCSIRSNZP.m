%ocuduCSIRSNZP Non-Zero-Power Channel-State Information Reference Signals.
%   [CSIRSSYMBOLS, SYMBOLINDICES] = ocuduCSIRSNZP(CARRIER, CSIRS, AMPLITUDE)
%   generates the NZP-CSI-RS sequence and stores it in CSIRSSYMBOLS. The
%   mapping indices are generated and stored in SYMBOLINDICES.
%
%   See also nrCarrierConfig, nrCSIRSConfig, nrCSIRS and nrCSIRSIndices.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [CSIRSsymbols, symbolIndices] = ocuduCSIRSNZP(carrier, csirs, amplitude)

    CSIRSsymbols = nrCSIRS(carrier, csirs);
    CSIRSsymbols = CSIRSsymbols * amplitude;
    symbolIndices = nrCSIRSIndices(carrier, csirs, 'IndexStyle', 'subscript', 'IndexBase', '0based');

