%ocuduSRSValidateConfig SRS configuration validator.
%   ISVALID = ocuduSRSValidateConfig(NRCARRIER, SRS) checks whether
%   the SRS configuration provided in SRS is valid for the
%   carrier NRCARRIER.
%
%   See also nrCarrierConfig, nrSRSConfig.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function isValid = ocuduSRSValidateConfig(nrCarrier, srs)

    isValid = true;

    % Skip any other check if the structure does not have any field.
    if isempty(fieldnames(srs))
        isValid = false;
        return;
    end

    % Validate input.
    SymbolStart = srs.SymbolStart;
    NumSRSSymbols = srs.NumSRSSymbols;
    if (SymbolStart + NumSRSSymbols) > nrCarrier.SymbolsPerSlot
        isValid = false;
        return;
    end 

 
    % In NR, Extended CP is only used with 60 kHz subcarrier spacing.
    if (strcmp(nrCarrier.CyclicPrefix, 'extended') && (nrCarrier.SubcarrierSpacing ~= 60))
        isValid = false;
        return;
    end

    try
        nrSRSIndices(nrCarrier, srs, 'IndexStyle', 'subscript', 'IndexBase', '0based');
    catch
        isValid = false;
        return;
    end
end
