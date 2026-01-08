%ocuduTransformPrecoderUnittest Unit tests for transform precoding functions.
%   This class implements unit tests for the transform precoding
%   functions using the matlab.unittest framework. The simplest use
%   consists in creating an object with 
%      testCase = ocuduTransformPrecoderUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduTransformPrecoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'transform_precoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/generic_functions/transform_precoding').
%
%   ocuduTransformPrecoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduTransformPrecoderUnittest Properties (TestParameter):
%
%   NumPRB               - Number of resource blocks.
%   NumOFDMSymbols       - Number of OFDM symbols to perform precoding.
%
%   ocuduTransformPrecoderUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduTransformPrecoderUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest, nrTransformPrecode, nrTransformDeprecode.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef ocuduTransformPrecoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'transform_precoder'

        %Type of the tested block.
        ocuduBlockType = 'phy/generic_functions/transform_precoding'

        %Number of OFDM symbols to apply transform precoding.
        NumOFDMSymbols = 8
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'transform_precoder' tests will be erased).
        outputPath = {['testTransformPrecoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Valid number of RB to apply transform precode.
        NumPRB = {...
              1,   2,   3,   4,   5,   6,   8,   9,  10,  12,  15,  16, ...
             18,  20,  24,  25,  27,  30,  32,  36,  40,  45,  48,  50, ...
             54,  60,  64,  72,  75,  80,  81,  90,  96, 100, 108, 120, ...
            125, 128, 135, 144, 150, 160, 162, 180, 192, 200, 216, 225, ...
            240, 243, 250, 256, 270};
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            fprintf(fileID, '#include "ocudu/adt/complex.h"\n');
            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.

            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, '  unsigned          M_rb;\n');
            fprintf(fileID, '  file_vector<cf_t>  deprecode_data_input;\n');
            fprintf(fileID, '  file_vector<float> deprecode_noise_input;\n');
            fprintf(fileID, '  file_vector<cf_t>  deprecode_data_output;\n');
            fprintf(fileID, '  file_vector<float> deprecode_noise_output;\n');
            fprintf(fileID, '};\n');
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, NumPRB)
        %testvectorGenerationCases Generates a test vectors given the MRB. 

            import ocuduTest.helpers.writeComplexFloatFile
            import ocuduTest.helpers.writeFloatFile
            import ocuduTest.helpers.randmod;
            import ocuduLib.phy.generic_functions.transform_precoding.ocuduTransformDeprecode;

            % Generate a unique test ID by looking at the number of files
            % generated so far.
            testID = testCase.generateTestID;

            % Calculate total number of subcarriers.
            NumSC = NumPRB * 12 * testCase.NumOFDMSymbols;

            % Generate random QPSK subcarriers.
            x = randmod('QPSK', [NumSC, 1]);

            % Apply transform precoding.
            precoded = nrTransformPrecode(x, NumPRB);

            % Generate noise variance.
            eqNoiseVar = rand() + rand(size(precoded)) / 10;

            % Deprecode.
            [deprecoded, noiseVar] = ocuduTransformDeprecode(precoded, eqNoiseVar, NumPRB, 1);

            % Save data before transform precoding.
            testCase.saveDataFile('_test_input_data', testID, @writeComplexFloatFile, precoded);
            testCase.saveDataFile('_test_input_noise', testID, @writeFloatFile, eqNoiseVar);

            % Save data after transform precoding.
            testCase.saveDataFile('_test_output_data', testID, @writeComplexFloatFile, deprecoded);
            testCase.saveDataFile('_test_output_noise', testID, @writeFloatFile, noiseVar);

            testCaseString = testCase.testCaseToString(testID, ...
                {NumPRB}, false, '_test_input_data', ...
                '_test_input_noise', '_test_output_data', ...
                '_test_output_noise');

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, ...
                testCaseString);

        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduTransformPrecoderUnittest
