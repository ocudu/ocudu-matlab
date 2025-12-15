%ocuduSRSValidateConfig SRS configuration validator.
%   ISVALID = ocuduSRSValidateConfig(NRCARRIER, SRS) checks whether
%   the SRS configuration provided in SRS is valid for the
%   carrier NRCARRIER.
%
%   See also nrCarrierConfig, nrSRSConfig.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

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
