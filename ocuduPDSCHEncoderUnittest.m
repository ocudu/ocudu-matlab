%ocuduPDSCHEncoderUnittest Unit tests for PDSCH encoder functions.
%   This class implements unit tests for the PDSCH encoder functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPDSCHEncoderUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPDSCHEncoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'pdsch_encoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors/pdsch').
%
%   ocuduPDSCHEncoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPDSCHEncoderUnittest Properties (TestParameter):
%
%   SymbolAllocation        - Symbols allocated to the PDSCH transmission.
%   PRBAllocation           - PRBs allocated to the PDSCH transmission.
%   mcs                     - Modulation scheme index (0, 28).
%
%   ocuduPDSCHEncoderUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduPDSCHEncoderUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduPDSCHEncoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'pdsch_encoder'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/channel_processors/pdsch'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'pdsch_encoder' tests will be erased).
        outputPath = {['testPDSCHEncoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Symbols allocated to the PDSCH transmission. The symbol allocation is described
        %   by a two-element array with the starting symbol (0...13) and the length (1...14)
        %   of the PDSCH transmission. Example: [0, 14].
        SymbolAllocation = {[0, 14], [1, 13], [2, 12]}

        %PRBs allocated to the PDSCH transmission. Two PRB allocation cases are covered:
        %   full usage (0) and partial usage (1).
        PRBAllocation = {0, 1}

        %Modulation and coding scheme index.
        mcs = num2cell(0:28)
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.

            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/codeblock_metadata.h"\n');

        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.

            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, '  segmenter_config         config;\n');
            fprintf(fileID, '  file_vector<uint8_t>     transport_block;\n');
            fprintf(fileID, '  file_vector<uint8_t>     encoded;\n');
            fprintf(fileID, '};\n');

        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, SymbolAllocation, PRBAllocation, mcs)
        %testvectorGenerationCases Generates a test vector for the given SymbolAllocation,
        %   PRBAllocation and mcs. Other parameters (e.g., the HARQProcessID) are
        %   generated randomly.

            import ocuduLib.phy.helpers.ocuduExpandMCS
            import ocuduLib.phy.helpers.ocuduGetModulation
            import ocuduTest.helpers.bitPack
            import ocuduTest.helpers.writeUint8File

            % Generate a unique test ID.
            testID = testCase.generateTestID;

            % Set randomized values.
            if PRBAllocation == 0
                PRBstart = 0;
                PRBend = 24;
            else
                PRBstart = randi([0, 12]);
                PRBend = randi([13, 24]);
            end
            HARQProcessID = randi([1, 8]);

            % Current fixed parameter values (e.g., single layer = single TB/codeword, no retransmissions).
            nSizeGrid = 25;
            nStartGrid = 0;
            numLayers = 1;
            nStartBWP = 0;
            nSizeBWP = nSizeGrid;
            PRBSet = PRBstart:PRBend;
            mcsTable = 'qam256';
            multipleHARQProcesses = true;
            rv = 0;
            cwIdx = 0;

            % Skip those invalid configuration cases.
            isMCSConfigOK = (~strcmp(mcsTable, 'qam256') || mcs < 28);

            if ~isMCSConfigOK
                return;
            end

            % Configure the carrier according to the test parameters.
            carrier = nrCarrierConfig(NSizeGrid=nSizeGrid, NStartGrid=nStartGrid);

            % Get the target code rate (R) and modulation order (Qm) corresponding to the current modulation and scheme configuration.
            [R, Qm] = ocuduExpandMCS(mcs, mcsTable);
            targetCodeRate = R/1024;
            [modulation, modulationOCUDU] = ocuduGetModulation(Qm);

            % Configure the PDSCH according to the test parameters.
            pdsch = nrPDSCHConfig( ...
                NStartBWP=nStartBWP, ...
                NSizeBWP=nSizeBWP, ...
                Modulation=modulation, ...
                NumLayers=numLayers, ...
                SymbolAllocation=SymbolAllocation, ...
                PRBSet=PRBSet ...
                );

            % Get the encoded TB length.
            [PDSCHIndices, PDSCHInfo] = nrPDSCHIndices(carrier, pdsch);
            nofREs = length(PDSCHIndices);
            encodedTBLength = nofREs * Qm;

            % Generate the TB to be encoded.
            TBSize = nrTBS(modulation, numLayers, numel(PRBSet), PDSCHInfo.NREPerPRB, targetCodeRate);
            TB = randi([0 1], TBSize, 1);

            % Write the packed format of the TB to a binary file.
            TBPkd = bitPack(TB);
            testCase.saveDataFile('_test_input', testID, @writeUint8File, TBPkd);

            % Configure the PDSCH encoder.
            DLSCHEncoder = nrDLSCH( ...
                MultipleHARQProcesses=multipleHARQProcesses, ...
                TargetCodeRate=targetCodeRate ...
                );

            % Add the generated TB to the encoder.
            setTransportBlock(DLSCHEncoder, TB, cwIdx, HARQProcessID);

            % Call the PDSCH encoding Matlab functions.
            cw = DLSCHEncoder(modulation, numLayers, encodedTBLength, rv, HARQProcessID);

            % Write the encoded TB to a binary file.
            testCase.saveDataFile('_test_output', testID, @writeUint8File, cw);

            % Obtain the related LDPC encoding parameters.
            info = nrDLSCHInfo(TBSize, targetCodeRate);

            % Generate the test case entry.
            Nref = DLSCHEncoder.LimitedBufferSize;
            % 25344 is the maximum coded length of a code block and implies no limit on the buffer size.
            if Nref >= 25344
              Nref = 0;
            end
            testCaseString = testCase.testCaseToString(testID, ...
                {['ldpc_base_graph_type::BG', num2str(info.BGN)], rv, ...
                    ['modulation_scheme::', modulationOCUDU], Nref, ...
                    numLayers, nofREs}, true, '_test_input', '_test_output');

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);

        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPDSCHEncoderUnittest
