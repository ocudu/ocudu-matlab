%ocuduPDSCHModulatorUnittest Unit tests for PDSCH symbol modulator functions.
%   This class implements unit tests for the PDSCH symbol modulator functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPDSCHModulatorUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPDSCHModulatorUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'pdsch_modulator').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors/pdsch').
%
%   ocuduPDSCHModulatorUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPDSCHModulatorUnittest Properties (TestParameter):
%
%   SymbolAllocation  - Symbols allocated to the PDSCH transmission.
%   Modulation        - Modulation scheme.
%   NumLayers         - Number of transmission layers.
%
%   ocuduPDSCHModulatorUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduPDSCHModulatorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduPDSCHModulatorUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'pdsch_modulator'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/channel_processors/pdsch'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'pdsch_modulator' tests will be erased).
        outputPath = {['testPDSCHModulator', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Symbols allocated to the PDSCH transmission. The symbol allocation is described
        %   by a two-element array with the starting symbol (0...13) and the length (1...14)
        %   of the PDSCH transmission. Example: [0, 14].
        SymbolAllocation = {[0, 14], [1, 13], [2, 12]}

        %Modulation scheme ('QPSK', '16QAM', '64QAM', '256QAM', '1024QAM').
        Modulation = {'QPSK', '16QAM', '64QAM', '256QAM', '1024QAM'}

        %Number of transmission layers (1, 2, 4, 8).
        NumLayers = {1, 2, 4, 8}

        %Virtual to physical resource block interleaved mapping bundle
        %size. Zero means no interleaving.
        VRBBundleSize = {0, 2, 4}
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            fprintf(fileID, '#include "resource_grid_test_doubles.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/channel_processors/pdsch/pdsch_modulator.h"\n');
            fprintf(fileID, '#include "ocudu/ran/precoding/precoding_codebooks.h"\n');
            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
        end
        function addTestDefinitionToHeaderFile(obj, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.
            fprintf(fileID, [...
                'struct context_t {\n' ...
                '  rnti_t rnti;\n' ...
                '  crb_interval bwp;\n' ...
                '  modulation_scheme modulation1;\n' ...
                '  std::optional<modulation_scheme> modulation2;\n' ...
                '  rb_allocation freq_allocation;\n' ...
                '  ofdm_symbol_range time_alloc;\n' ...
                '  symbol_slot_mask dmrs_symb_pos;\n' ...
                '  dmrs_config_type dmrs_type;\n' ...
                '  unsigned nof_cdm_groups_without_data;\n' ...
                '  unsigned n_id;\n' ...
                '  float scaling;\n' ...
                '  re_pattern_list reserved;\n' ...
                '  unsigned nof_layers;\n' ...
                '};\n' ...
                '\n' ...
                'struct test_case_t {\n' ...
                '  context_t context;\n' ...
                '  file_vector<uint8_t> data;\n' ...
                '  file_vector<resource_grid_writer_spy::expected_entry_t> symbols;\n' ...
                '};\n'...
            ]);
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, SymbolAllocation, Modulation, NumLayers, VRBBundleSize)
        %testvectorGenerationCases Generates a test vector for the given SymbolAllocation,
        %   Modulation scheme and number of layers. Other parameters (e.g.,
        %   the RNTI) are generated randomly.

            import ocuduLib.phy.helpers.ocuduGetBitsSymbol
            import ocuduLib.phy.helpers.ocuduModulationFromMatlab
            import ocuduLib.phy.upper.channel_processors.ocuduPDSCHmodulator
            import ocuduLib.phy.upper.signal_processors.ocuduPDSCHDMRS
            import ocuduTest.helpers.array2str
            import ocuduTest.helpers.symbolAllocationMask2string
            import ocuduTest.helpers.writeResourceGridEntryFile
            import ocuduTest.helpers.writeUint8File

            % Generate a unique test ID.
            testID = testCase.generateTestID;

            % Generate default carrier configuration.
            carrier = nrCarrierConfig();

            % Set randomized values.
            NSizeBWP = randi([carrier.NSizeGrid / 2, carrier.NSizeGrid]);
            NStartBWP = randi([0, carrier.NSizeGrid - NSizeBWP]);
            NID = randi([1, 1023]);
            RNTI = randi([1, 65535]);
            startPRB = randi([0, NSizeBWP - 2]);
            endPRB = randi([startPRB + 1, NSizeBWP - 1]);

            VRBToPRBInterleaving = (VRBBundleSize ~= 0);
            VRBBundleSize = max([2, VRBBundleSize]);

            % Determine the number of codewords. For more than 4 layers,
            % two codewords are used.
            numCWs = 1;
            if (NumLayers > 4)
                numCWs = 2;
            end

            % Configure the PDSCH according to the test parameters.
            pdsch = nrPDSCHConfig( ...
                NSizeBWP=NSizeBWP, ...
                NStartBWP=NStartBWP, ...
                Modulation=Modulation, ...
                NumLayers=NumLayers, ...
                SymbolAllocation=SymbolAllocation, ...
                PRBSet=startPRB:endPRB, ...
                VRBToPRBInterleaving=VRBToPRBInterleaving, ...
                VRBBundleSize=VRBBundleSize, ...
                NID=NID, ...
                RNTI=RNTI ...
                );

            % DM-RS Type 1 requires TDD OCC for more than four ports.
            if (NumLayers > 4)
                pdsch.DMRS = nrPDSCHDMRSConfig('DMRSLength', 2);
            end

            modOrder1 = ocuduGetBitsSymbol(pdsch.Modulation);
            modString1 = ocuduModulationFromMatlab(pdsch.Modulation, 'full');

            % Calculate number of encoded bits.
            nBits = length(nrPDSCHIndices(carrier, pdsch, "IndexStyle", "subscript")) * modOrder1;
            
            % Generate codeword bits.
            cwData = randi([0, 1], nBits, 1);

            if (numCWs == 2)
                % Build codeword-specific bit arrays.
                cwDataSplit = reshape(cwData, [nBits / numCWs, numCWs]);
                % Arrange codewords in cell array, one column vector per codeword.
                cws = mat2cell(cwDataSplit, nBits / numCWs, ones(1, numCWs));
            else
                cws = cwData;
            end

            % Write the DLSCH cw to a binary file.
            testCase.saveDataFile('_test_input', testID, @writeUint8File, cwData);

            % Call the PDSCH symbol modulation Matlab functions.
            [modulatedSymbols, symbolIndices] = ocuduPDSCHmodulator(carrier, pdsch, cws);

            % Write each complex symbol into a binary file, and the associated indices to another.
            testCase.saveDataFile('_test_output', testID, ...
                @writeResourceGridEntryFile, modulatedSymbols, symbolIndices);

            % Generate DM-RS symbol mask.
            [~, symbolIndices] = ocuduPDSCHDMRS(carrier, pdsch);
            dmrsSymbolMask = symbolAllocationMask2string(symbolIndices);

            % Generate the test case entry.
            reservedString = '{}';

            if VRBToPRBInterleaving
                RBAllocationString = sprintf('rb_allocation::make_type1(%d, %d, create_interleaved_other(%d, %d, vrb_to_prb::mapping_type::interleaved_n%d))', startPRB, length(pdsch.PRBSet), NStartBWP, NSizeBWP, VRBBundleSize);
            else
                RBAllocationString = sprintf('rb_allocation::make_type1(%d, %d, vrb_to_prb::create_non_interleaved_other())', startPRB, length(pdsch.PRBSet));
            end
            DMRSTypeString = sprintf('dmrs_config_type::type%d', pdsch.DMRS.DMRSConfigurationType);

            rntiString = ['to_rnti(', num2str(pdsch.RNTI), ')'];
            precodingString = ['precoding_configuration::make_wideband(make_identity(' num2str(NumLayers) '))'];

            bwpConfig = {NStartBWP, NStartBWP + NSizeBWP};
            timeAlloc= {pdsch.SymbolAllocation(1), sum(pdsch.SymbolAllocation)};

            % The second modulation is only present when two codewords are used.
            if (numCWs == 2)
                modString2 = modString1;
            else
                modString2 = 'std::nullopt';
            end

            % The precoding configuration is built at runtime in the test from
            % the number of layers.
            configCell = {...
                rntiString, ...                         % rnti
                bwpConfig, ...                          % bwp
                modString1, ...                         % modulation1
                modString2, ...                         % modulation2
                RBAllocationString, ...                 % freq_allocation
                timeAlloc, ...                          % time_alloc
                dmrsSymbolMask, ...                     % dmrs_symb_pos
                DMRSTypeString, ...                     % dmrs_config_type
                pdsch.DMRS.NumCDMGroupsWithoutData, ... % nof_cmd_groups_without_data
                pdsch.NID, ...                          % n_id
                1.0, ...                                % scaling
                reservedString, ...                     % reserved
                NumLayers ...                           % nof_layers
            };

            testCaseString = testCase.testCaseToString(testID, ...
                configCell, true, '_test_input', '_test_output');

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);

        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPDSCHModulatorUnittest
