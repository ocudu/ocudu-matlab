%ocuduPDSCHDMRSUnittest Unit tests for PDSCH DM-RS processor functions.
%   This class implements unit tests for the PDSCH DM-RS processor functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%       testCase = ocuduPDSCHDMRSUnittest
%   and then running all the tests with
%       testResults = testCase.run
%
%   ocuduPDSCHDMRSUnittest Properties (Constant):
%
%   ocuduBlock              - The tested block (i.e., 'dmrs_pdsch_processor').
%   ocuduBlockType          - The type of the tested block, including layer
%                             (i.e., 'phy/upper/signal_processors/pdsch').
%   ValidDMRSReferencePoint - DM-RS reference points.
%
%   ocuduPDSCHDMRSUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPDSCHDMRSUnittest Properties (TestParameter):
%
%   numerology              - Defines the subcarrier spacing (0, 1).
%   DMRSPortConfig          - DM-RS configuration type, DM-RS ports and number of
%                             front-loaded DM-RS symbols, as per the antenna port
%                             combinations of TS38.212 Section 7.3.1.2.2.
%
%   ocuduPDSCHDMRSUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduPDSCHDMRSUnittest Methods (Static, TestParameterDefinition):
%
%   initializeDMRSPortConfig - Lists the DM-RS port configurations.
%
%   ocuduPDSCHDMRSUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduPDSCHDMRSUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'dmrs_pdsch_processor'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/signal_processors/pdsch'

        %List of valid DM-RS reference points.
        ValidDMRSReferencePoint = {'CRB0', 'PRB0'}
    end

    properties (Hidden)
        randomizeTestvector
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'dmrs_pdsch_processor' tests will be erased).
        outputPath = {['testPDSCHDMRS', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Defines the subcarrier spacing (0, 1).
        numerology = {0, 1}

        %DM-RS configuration type, DM-RS ports and number of front-loaded DM-RS
        %symbols (see initializeDMRSPortConfig).
        DMRSPortConfig
    end

    methods (Static, TestParameterDefinition)
        function DMRSPortConfig = initializeDMRSPortConfig()
        %initializeDMRSPortConfig Lists the DM-RS port configurations.
        %   The configurations are the antenna port combinations of TS38.212 Tables
        %   7.3.1.2.2-2 and 7.3.1.2.2-4 (i.e., DM-RS maximum length of two), which
        %   contain the combinations of Tables 7.3.1.2.2-1 and 7.3.1.2.2-3. The
        %   generated DM-RS does not depend on the number of CDM groups without data.
        %   Therefore, only the combinations with the maximum number of CDM groups
        %   without data of the DM-RS type are tested.

            import ocuduTest.helpers.pdschDMRSPortTable

            % Maximum number of CDM groups without data for DM-RS types 1 and 2.
            maxNumCDMGroupsWithoutData = [2, 3];

            DMRSPortConfig = struct();
            for dmrsType = 1:2
                portTable = pdschDMRSPortTable(dmrsType, 2);
                for entry = portTable.'
                    numCDMGroupsWithoutData = entry.NumCDMGroupsWithoutData;
                    if numCDMGroupsWithoutData ~= maxNumCDMGroupsWithoutData(dmrsType)
                        continue;
                    end

                    cwString = '';
                    if entry.NumCodewords == 2
                        cwString = 'TwoCW';
                    end
                    configName = sprintf('Type%d%sValue%d', dmrsType, cwString, ...
                        entry.Value);

                    DMRSPortConfig.(configName) = struct( ...
                        'DMRSConfigurationType', dmrsType, ...
                        'DMRSPortSet', entry.DMRSPorts, ...
                        'DMRSLength', entry.NumFrontLoadSymbols);
                end
            end
        end
    end % of methods (Static, TestParameterDefinition)

    methods (Access = protected)
        function addTestIncludesToHeaderFile(obj, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            addTestIncludesToHeaderFilePHYsigproc(obj, fileID);
            fprintf(fileID, '#include "ocudu/ran/precoding/precoding_codebooks.h"\n');
        end

        function addTestDefinitionToHeaderFile(obj, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.
            addTestDefinitionToHeaderFilePHYsigproc(obj, fileID);
        end

        function initializeClassImpl(obj)
            obj.randomizeTestvector = randperm(1008);
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, numerology, DMRSPortConfig)
        %testvectorGenerationCases Generates a test vector for the given numerology
        %   and DM-RS port configuration. NCellID, NSlot, scrambling ID, BWP start,
        %   DM-RS reference point, DM-RS type A position, DM-RS additional positions,
        %   symbol allocation and PRB allocation are randomly generated. The PRB
        %   allocation is either contiguous or non-contiguous with probability 1/2.

            import ocuduTest.helpers.cellarray2str
            import ocuduLib.phy.upper.signal_processors.ocuduPDSCHDMRS
            import ocuduTest.helpers.writeResourceGridEntryFile
            import ocuduTest.helpers.symbolAllocationMask2string
            import ocuduTest.helpers.RBallocationMask2string
            import ocuduTest.helpers.randomNonContiguousPRBSet
            import ocuduTest.helpers.dmrsPortMask2string

            % Generate a unique test ID.
            testID = testCase.generateTestID;

            % DM-RS port configuration.
            DMRSConfigurationType = DMRSPortConfig.DMRSConfigurationType;
            DMRSPortSet = DMRSPortConfig.DMRSPortSet;
            DMRSLength = DMRSPortConfig.DMRSLength;
            NumLayers = numel(DMRSPortSet);

            % Position of the first DM-RS OFDM symbol and number of DM-RS additional
            % positions. Double-symbol DM-RS supports one additional position at most.
            DMRSTypeAPosition = randi([2, 3]);
            if (DMRSLength == 1)
                DMRSAdditionalPosition = randi([0, 3]);
            else
                DMRSAdditionalPosition = randi([0, 1]);
            end

            % Use a unique NCellID, NSlot, scrambling ID and PRB allocation
            % for each test.
            nCellID = testCase.randomizeTestvector(testID + 1) - 1;
            if numerology == 0
                nSlot = randi([0, 9]);
            else
                nSlot = randi([0, 19]);
            end
            NSCID = randi([0, 1]);
            NIDNSCID = randi([0, 65535]);

            % Current fixed parameter values (e.g., number of CDM groups
            % without data).
            nSizeGrid = 272;
            nStartGrid = 0;
            nFrame = 0;
            cyclicPrefix = 'normal';
            RNTI = 0;
            nID = nCellID;
            reservedRE = [];
            modulation = '16QAM';
            mappingType = 'A';
            amplitude = 0.5;

            % BWP allocation, referenced to CRB0.
            nStartBWP = randi([0, 10]);
            nSizeBWP = nSizeGrid - nStartBWP;

            % DM-RS subcarrier reference point.
            DMRSReferencePoint = testCase.ValidDMRSReferencePoint{randi([1, numel(testCase.ValidDMRSReferencePoint)])};
            referencePointKrb = 0;
            if strcmp(DMRSReferencePoint, 'PRB0')
                referencePointKrb = nStartBWP;
            end

            % Mapping type A: the allocation must contain the first DM-RS (both
            % symbols for double-symbol DM-RS) plus at least one more symbol, and
            % last at least three symbols.
            symbolStart = randi([0, DMRSTypeAPosition]);
            minLength = max(3, DMRSTypeAPosition + DMRSLength + 1 - symbolStart);
            symbolAllocation = [symbolStart, randi([minLength, 14 - symbolStart])];

            % Pick contiguous and non-contiguous allocations with probability 0.5.
            if (rand < 0.5)
                % Keep the highest CRB at least 2, as required by the C++ test.
                PRBstart = randi([max(0, 2 - nStartBWP), nSizeBWP - 1]);
                maxPRB = nSizeBWP - PRBstart;
                if (rand < 0.25)
                    % Small allocation.
                    maxPRB = min(4, maxPRB);
                end

                PRBSet = PRBstart + (0:randi([1, maxPRB]) - 1);
            else
                PRBSet = randomNonContiguousPRBSet(nSizeBWP);
            end

            % Configure the carrier according to the test parameters.
            subcarrierSpacing = 15 * (2 .^ numerology);
            carrier = nrCarrierConfig( ...
                NCellID=nCellID, ...
                SubcarrierSpacing=subcarrierSpacing, ...
                NSizeGrid=nSizeGrid, ...
                NStartGrid=nStartGrid, ...
                NSlot=nSlot, ...
                NFrame=nFrame, ...
                CyclicPrefix=cyclicPrefix ...
                );

            % Configure the PDSCH DM-RS symbols according to the test
            % parameters.
            DMRS = nrPDSCHDMRSConfig( ...
                DMRSConfigurationType=DMRSConfigurationType, ...
                DMRSTypeAPosition=DMRSTypeAPosition, ...
                DMRSAdditionalPosition=DMRSAdditionalPosition, ...
                DMRSLength=DMRSLength, ...
                NIDNSCID=NIDNSCID, ...
                NSCID=NSCID, ...
                DMRSReferencePoint=DMRSReferencePoint, ...
                DMRSPortSet=DMRSPortSet ...
                );

            % Configure the PDSCH according to the test parameters.
            pdsch = nrPDSCHConfig( ...
                DMRS=DMRS, ...
                NStartBWP=nStartBWP, ...
                NSizeBWP=nSizeBWP, ...
                NID=nID, ...
                RNTI=RNTI, ...
                ReservedRE=reservedRE, ...
                Modulation=modulation, ...
                NumLayers=NumLayers, ...
                MappingType=mappingType, ...
                SymbolAllocation=symbolAllocation, ...
                PRBSet=PRBSet ...
                );

            % Call the PDSCH DM-RS symbol processor MATLAB functions.
            [DMRSsymbols, symbolIndices] = ocuduPDSCHDMRS(carrier, pdsch);

            % Write each complex symbol into a binary file, and the
            % associated indices to another.
            testCase.saveDataFile('_test_output', testID, ...
                @writeResourceGridEntryFile, amplitude * DMRSsymbols, symbolIndices);

            % Generate a 'slot_point' configuration string.
            slotPointConfig = cellarray2str({numerology, nFrame, ...
                floor(nSlot / carrier.SlotsPerSubframe), ...
                rem(nSlot, carrier.SlotsPerSubframe)}, true);

            % Generate a symbol allocation mask string.
            symbolAllocationMask = symbolAllocationMask2string(symbolIndices);

            % Generate a RB allocation mask string.
            rbAllocationMask = RBallocationMask2string(PRBSet + nStartBWP);

            precodingString = ['precoding_beamforming_configuration::make_wideband(make_identity(' num2str(NumLayers) '))'];
            dmrsTypeString = ['dmrs_config_type::type', num2str(DMRSConfigurationType)];
            dmrsPortsString = dmrsPortMask2string(DMRSPortSet);

            configCell = {...
                slotPointConfig, ...                                     % slot
                referencePointKrb, ...                                   % reference_point_k_rb
                dmrsTypeString, ...                                      % type
                NIDNSCID, ...                                            % scrambling_id
                NSCID,...                                                % n_scid
                amplitude, ...                                           % amplitude
                symbolAllocationMask, ...                                % symbols_mask
                rbAllocationMask, ...                                    % rb_mask
                dmrsPortsString, ...                                     % dmrs_ports
                precodingString...                                       % precoding
            };

            % Generate the test case entry.
            testCaseString = testCase.testCaseToString(testID, configCell, ...
                    true, '_test_output');

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);
        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPDSCHDMRSUnittest
