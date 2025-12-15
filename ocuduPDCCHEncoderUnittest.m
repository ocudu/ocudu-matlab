%ocuduPDCCHEncoderUnittest Unit tests for PDCCH encoder functions.
%   This class implements unit tests for the PDCCH encoder functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPDCCHEncoderUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPDCCHEncoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'pdcch_encoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors/pdcch').
%
%   ocuduPDCCHEncoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPDCCHEncoderUnittest Properties (TestParameter):
%
%   DCIlength        - DCI message length
%   Duration         - CORESET Duration.
%   AggregationLevel - PDCCH aggregation level.
%
%   ocuduPDCCHEncoderUnittest Methods (Test, TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduPDCCHModulatorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef ocuduPDCCHEncoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'pdcch_encoder'

        %Type of the tested block, including layer.
        ocuduBlockType = 'phy/upper/channel_processors/pdcch'

        %Number of resource elements per CCE (6 PRBs per CCE, 9 REs per PRB)
        nofREsPerCCE = (12 - 3) * 6;
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'pdcch_encoder' tests will be erased).
        outputPath = {['testPDCCHencoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        % PDCCH aggregation level (1, 2, 4, 8, 16).
        aggregationLevel= {1, 2, 4, 8, 16}

        % DCI formats.
        DCIlength = {12, 28, 39, 41, 60, 128}
    end % of properties (TestParameter)

    methods (Access = protected)
        function addTestIncludesToHeaderFile(obj, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            addTestIncludesToHeaderFilePHYchproc(obj, fileID);
        end

        function addTestDefinitionToHeaderFile(obj, fileID)
        %addTestDefinitionToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.
            addTestDefinitionToHeaderFilePHYchproc(obj, fileID);
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, aggregationLevel, DCIlength)
        % testvectorGenerationCases Generates a test vector for the given
        % aggregation level, while using randomly generated RNTI and codeword.

            import ocuduTest.helpers.cellarray2str
            import ocuduTest.helpers.writeUint8File

            % generate a unique test ID by looking at the number of files generated so far
            testID = testCase.generateTestID;

            % use a random RNTI for each test
            RNTI = randi([0, 65535]);

            % set number of message bits accounting for 24bit CRC
            encoderConfig.K = DCIlength + 24;
            % set number of available bits based on the current aggregation level
            encoderConfig.E = aggregationLevel * testCase.nofREsPerCCE * 2;
            % set generated RNTI
            encoderConfig.RNTI = RNTI;

            isTestCaseValid = encoderConfig.E >= encoderConfig.K;

            if isTestCaseValid
                message = randi([0 1], DCIlength, 1);

                % write the random DCI message to a binary file
                testCase.saveDataFile('_test_input', testID, @writeUint8File, message);

                % call MATLAB function for DCI encoding
                encodedMsg = nrDCIEncode(message, RNTI, encoderConfig.E);

                % write the encoded codeword to a binary file
                testCase.saveDataFile('_test_output', testID, @writeUint8File, encodedMsg);

                % generate the test case entry
                testCaseString = testCase.testCaseToString(testID, ...
                    {encoderConfig.E, encoderConfig.RNTI}, true, ...
                    '_test_input', '_test_output');

                % add the test to the file header
                testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);
            end
        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPDCCHEncoderUnittest
