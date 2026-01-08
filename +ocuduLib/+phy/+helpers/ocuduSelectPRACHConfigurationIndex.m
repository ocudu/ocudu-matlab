%ocuduSelectPRACHConfigurationIndex selects a valid configuration index.
%   CONFIGURATIONINDEX = ocuduSelectPRACHConfigurationIndex(DUPLEXMODE, PREAMBLEFORMAT)
%   Gets the first configuration index CONFIGURATIONINDEX in a configurations table 
%   selected by the duplex mode DUPLEXMODE with the given preamble format PREAMBLEFORMAT.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function ConfigurationIndex = ocuduSelectPRACHConfigurationIndex(FrequencyRange, DuplexMode, PreambleFormat)
    % Select table from the corresponding duplex mode.
    if strcmp(FrequencyRange, 'FR2')
        assert(strcmp(DuplexMode, 'TDD'))
        table = nrPRACHConfig.Tables.ConfigurationsFR2;
    elseif strcmp(DuplexMode, 'FDD')
        assert(strcmp(FrequencyRange, 'FR1'))
        table = nrPRACHConfig.Tables.ConfigurationsFR1PairedSUL;
    elseif strcmp(DuplexMode, 'TDD')
        assert(strcmp(FrequencyRange, 'FR1'))
        table = nrPRACHConfig.Tables.ConfigurationsFR1Unpaired;
    else
        error('Unhandled duplex mode %s.', DuplexMode);
    end
    
    % Find the first row index in the table that matches the preamble format.
    rowIndex = find(strcmp(table.PreambleFormat, PreambleFormat), 1);
    ConfigurationIndex = table.ConfigurationIndex(rowIndex);
end
