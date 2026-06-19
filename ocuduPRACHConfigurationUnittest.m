%ocuduPRACHConfigurationUnittest Unit tests for PRACH configurations.
%   This class dumps the PRACH configuration tables provided by nrPRACHConfig into
%   a format that is readable by the OCUDU unit tests.
%
%   ocuduPRACHConfigurationUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'prach_configuration').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'ran/prach').
%
%   ocuduPRACHConfigurationUnittest Properties (ClassSetupParameter):
%
%   outputPath  - Path to the folder where the test results are stored.
%
%   ocuduPRACHConfigurationUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generate all the PRACH configuration tables.
%
%   ocuduPRACHConfigurationUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest, nrPRACHConfig.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduPRACHConfigurationUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'prach_configuration'

        %Type of the tested block.
        ocuduBlockType = 'ran/prach'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'prach_configuration' tests will be erased).
        outputPath = {['testPRACHConfiguration', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            fprintf(fileID, [...
                '#include "ocudu/ran/prach/prach_configuration.h"\n' ...
                '#include <vector>\n' ...
                ]);
        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.

            fprintf(fileID, [ ...
                'struct test_case_t {\n' ...
                '  frequency_range      fr;\n' ...
                '  duplex_mode          dm;\n' ...
                '  uint8_t              index;\n' ...
                '  prach_configuration  config;\n' ...
                '};\n' ...
                ]);
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(obj)
            tableNames = [ ...
                ... TS38.211 Table 6.3.3.2-2: Random access configurations for
                ... FR1 and paired spectrum/supplementary uplink.
                "ConfigurationsFR1PairedSUL", ...
                ... TS38.211 Table 6.3.3.2-3: Random access configurations for
                ... FR1 and unpaired spectrum.
                "ConfigurationsFR1Unpaired", ...
                ... TS38.211 Table 6.3.3.2-4: Random access configurations for
                ... FR2 and unpaired spectrum.
                "ConfigurationsFR2"
                ];


            for tt = tableNames
                % Load the PRACH configuration table.
                configTable = nrPRACHConfig.Tables.(tt);

                % Remove empty rows.
                configTable = configTable(~matches(configTable.PreambleFormat, '-'), :);
                nConfigs = size(configTable, 1);

                % Set frequency range and duplex mode according to the selected table.
                if (tt == "ConfigurationsFR1PairedSUL")
                    freqRange = 'frequency_range::FR1';
                    duplexMode = 'duplex_mode::FDD';
                elseif (tt == "ConfigurationsFR1Unpaired")
                    freqRange = 'frequency_range::FR1';
                    duplexMode = 'duplex_mode::TDD';
                else
                    freqRange = 'frequency_range::FR2';
                    duplexMode = 'duplex_mode::TDD';
                end

                for iConfig = 1:nConfigs
                    thisConfig = configTable(iConfig, :);

                    ocuduPRACHformat = sprintf('to_prach_format_type("%s")', thisConfig.PreambleFormat{1});
                    x = thisConfig.x;
                    y = thisConfig.y{1};

                    % In OCUDU, the PRACH configuration structure does not differentiate
                    % between FR1 subframes and FR2 slots.
                    if (tt ~= "ConfigurationsFR2")
                        slots = thisConfig.SubframeNumber{1};
                        nSlotsSubframe = thisConfig.PRACHSlotsPerSubframe;
                    else
                        slots = thisConfig.SlotNumber{1};
                        nSlotsSubframe = thisConfig.PRACHSlotsPer60kHzSlot;
                    end

                    startingSymbol = thisConfig.StartingSymbol;

                    % In OCUDU, N/A fields are set to zero and not to NaN as in MATLAB.
                    if isnan(nSlotsSubframe)
                        nSlotsSubframe = 0;
                    end
                    nOccasions = thisConfig.NumTimeOccasions;
                    if isnan(nOccasions)
                        nOccasions = 0;
                    end

                    duration = thisConfig.PRACHDuration;

                    config = { ...
                        ocuduPRACHformat, ...    % format
                        x, ...                 % x
                        {y}, ...               % y
                        {slots}, ...           % slots
                        startingSymbol, ...    % starting_symbol
                        nSlotsSubframe, ...    % nof_prach_slots_within_subframe
                        nOccasions, ...        % nof_occasions_within_slot
                        duration, ...          % duration
                        };

                    testCaseString = obj.testCaseToString(0, {freqRange, duplexMode, iConfig - 1, config}, false);

                    % Add the test case entry.
                    obj.addTestToHeaderFile(obj.headerFileID, testCaseString);

                end % of for iConfig = 1:nConfigs
            end % of for tt = tableNames
        end % of function testvectorGenerationCases(obj)

    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPRACHConfigurationUnittest < ocuduBlockUnittest
