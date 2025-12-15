%ocuduLDPCEncoderUnittest Unit tests for the LDPC encoder.
%   This class implements unit tests for the LDPC encoder using the matlab.unittest
%   framework. The simplest use consists in creating an object with
%       testCase = ocuduLDPCEncoderUnittest
%   and then running all the tests with
%       testResults = testCase.run
%
%   ocuduLDPCEncoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'ldpc_encoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., '/phy/upper/channel_coding/ldpc').
%
%   ocuduLDPCEncoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduLDPCEncoderUnittest Properties (TestParameter):
%
%   baseGraph  - LDPC base graph.
%   liftSize   - Lifting size accepted by NR LDPC codes.
%
%   ocuduLDPCEncoderUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector for the given base graph
%                               and lifting size.
%
%   ocuduLDPCEncoderUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest, nrLDPCEncode.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef ocuduLDPCEncoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'ldpc_encoder'

        %Type of the tested block, including layers.
        ocuduBlockType = 'phy/upper/channel_coding/ldpc'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'ldpc_encoder' tests will be erased).
        outputPath = {['testLDPCencoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %LDPC base graph (1, 2).
        baseGraph = {1, 2}

        %Lifting size accepted by NR LDPC codes.
        liftSize = num2cell(ocuduLib.phy.upper.channel_coding.ldpc.ocuduLDPCLiftingSizes)
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile(OBJ, FILEID) adds include directives to
        %   the header file pointed by FILEID, which describes the test vectors.

            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDefinitionToHeaderFile(OBJ, FILEID) adds test details (e.g., type
        %   and variable declarations) to the header file pointed by FILEID, which
        %   describes the test vectors.

            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, 'unsigned nof_messages            = 0;\n');
            fprintf(fileID, 'unsigned bg                      = 0;\n');
            fprintf(fileID, 'unsigned ls                      = 0;\n');
            fprintf(fileID, 'file_vector<uint8_t> messages;\n');
            fprintf(fileID, 'file_vector<uint8_t> codeblocks;\n');
            fprintf(fileID, '};\n');
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(obj, baseGraph, liftSize)
        %testvectorGenerationCases Generates a test vector for the given base graph
        %   and lifting size.

            import ocuduTest.helpers.writeUint8File

            % Generate a unique test ID.
            testID = obj.generateTestID;

            baseMsgLength = 22;
            if baseGraph == 2
                baseMsgLength = 10;
            end

            msgLength = baseMsgLength * liftSize;

            % Fraction of filler bits.
            fracFillers = 0.1;

            nFiller = ceil(msgLength * fracFillers);

            % Random messages.
            nMessages = 10;
            messages = [randi([0, 1], msgLength - nFiller, nMessages); ...
                -1 * ones(nFiller, nMessages)];

            % Encode.
            codeblocks = nrLDPCEncode(messages, baseGraph);

            % Use OCUDU convention for filler bits.
            messages(messages == -1) = 254;
            codeblocks(codeblocks == -1) = 254;

            % Write messages.
            obj.saveDataFile('_test_input', testID, @writeUint8File, messages(:));

            % Write codeblocks.
            obj.saveDataFile('_test_output', testID, @writeUint8File, codeblocks(:));

            % Generate the test case entry.
            testCaseString = obj.testCaseToString(testID, {nMessages, ...
                baseGraph, liftSize}, false, '_test_input', '_test_output');

            % Add the test to the file header.
            obj.addTestToHeaderFile(obj.headerFileID, testCaseString);

        end % of function addTestIncludesToHeaderFile
    end % of methods (Access = protected)

end % of classdef ocuduLDPCEncoderUnittest
