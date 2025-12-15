%ocuduPBCHEncoderUnittest Unit tests for PBCH encoder functions.
%   This class implements unit tests for the PBCH encoder functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPBCHEncoderUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPBCHEncoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'pbch_encoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors/ssb').
%
%   ocuduPBCHEncoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPBCHEncoderUnittest Properties (TestParameter):
%
%   SSBindex - SSB index (0...63).
%   Lmax     - Maximum number of SSBs within a SSB set (4, 8, 64).
%   hrf      - Half frame bit in SS/PBCH block transmissions (0, 1).
%
%   ocuduPBCHEncoderUnittest Methods (Test, TestTags = {'testvector'}):
%
%   testvectorGenerationCases  - Generates test vectors for a given SSB index,
%                                Lmax and hrf, using random NCellID, SFN, kSSB and
%                                payload for each test.
%
%   ocuduPBCHModulatorUnittest Methods (Access = protected):
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

classdef ocuduPBCHEncoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'pbch_encoder'

        %Type of the tested block, including layer.
        ocuduBlockType = 'phy/upper/channel_processors/ssb'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'pbch_encoder' tests will be erased).
        outputPath = {['testPBCHencoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %SSB index (0...63).
        SSBindex = num2cell(0:63)

        %Maximum number of SSBs within a SSB set (4, 8 (default), 64).
        %Lmax = 4 is not currently supported, and Lmax = 64 and Lmax = 8
        %are equivalent at this stage.
        Lmax = {4, 8, 64}

        %Half frame bit in SS/PBCH block transmissions (0, 1).
        hrf = {0, 1}
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
        function testvectorGenerationCases(testCase, SSBindex, Lmax, hrf)
        %testvectorGenerationCases Generates 'pbch_encoder' test vectors.
        %   testvectorGenerationCases(TESTCASE, SSBINDEX, LMAX) generates a 'pbch_encoder'
        %   test vector for the given SSB index SSBINDEX, the given LMAX, and the given
        %   HRF using a random NCellID, a random SFN, a random KSSB and a random payload.

            import ocuduTest.helpers.writeUint8File
            import ocuduLib.phy.upper.channel_processors.ssb.ocuduPBCHencoder

            % generate a unique test ID by looking at the number of files generated so far
            testID = testCase.generateTestID;

            % use a unique NCellID, SFN, KSSB and payload for each test
            NCellIDLoc = randi([0, 1007]);
            SFNLoc = randi([0, 1023]);
            if Lmax == 64
                kSSBLoc = randi([0, 11]);
            else
                kSSBLoc = randi([0, 23]);
            end
            payload = randi([0, 1], 24, 1);

            % skip PBCH encoding for invalid configurations
            isSSBindexOK = Lmax > SSBindex;

            if isSSBindexOK
                return;
            end

            % call the PBCH encoder MATLAB functions
            cw = ocuduPBCHencoder(payload, NCellIDLoc, SSBindex, Lmax, SFNLoc, hrf, kSSBLoc);

            % write the encoded codeword to a binary file
            testCase.saveDataFile('_test_output', testID, @writeUint8File, cw);

            % generate the test case entry
            testCaseString = testCase.testCaseToString(testID, ...
                {NCellIDLoc, SSBindex, Lmax, hrf, payload, SFNLoc, kSSBLoc}, ...
                true, '_test_output');

            % add the test to the file header
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);
        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPBCHEncoderUnittest
