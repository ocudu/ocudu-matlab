%ocuduPBCHModulatorUnittest Unit tests for PBCH symbol modulator functions.
%   This class implements unit tests for the PBCH symbol modulator functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPBCHModulatorUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPBCHModulatorUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'pbch_modulator').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors/ssb').
%
%   ocuduPBCHModulatorUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPBCHModulatorUnittest Properties (TestParameter):
%
%   SSBindex - SSB index (0...7).
%   Lmax     - Maximum number of SSBs within a SSB set (4, 8 (default), 64).
%   NCellID  - PHY-layer cell ID (0...1007).
%
%   ocuduPBCHModulatorUnittest Methods (Test, TestTags = {'testvector'}):
%
%   testvectorGenerationCases  - Generates test vectors for a given SSB index
%                                and Lmax using random NCellID and cw for each test.
%
%   ocuduPBCHModulatorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef ocuduPBCHModulatorUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'pbch_modulator'

        %Type of the tested block, including layer.
        ocuduBlockType = 'phy/upper/channel_processors/ssb'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'pbch_modulator' tests will be erased).
        outputPath = {['testPBCHmodulator', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %SSB index (0...7).
        SSBindex = num2cell(0:7)

        %PHY-layer cell ID (0...1007).
        NCellID = num2cell(0:1007)

        %Maximum number of SSBs within a SSB set (4, 8 (default), 64).
        %Lmax = 4 is not currently supported, and Lmax = 64 and Lmax = 8
        %are equivalent at this stage.
        Lmax = {8}
    end % of properties (TestParameter)

    properties (Hidden)
        randomizeTestvector
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.
            fprintf(fileID, [...
                '#include "resource_grid_test_doubles.h"\n'...
                '#include "ocudu/phy/upper/channel_processors/ssb/pbch_modulator.h"\n'...
                '#include "ocudu/support/file_vector.h"\n'...
                ]);
        end

        function addTestDefinitionToHeaderFile(obj, fileID)
        %addTestDefinitionToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.
            addTestDefinitionToHeaderFilePHYchproc(obj, fileID);
        end

        function initializeClassImpl(obj)
            obj.randomizeTestvector = randperm(1008);
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, SSBindex, Lmax)
        %testvectorGenerationCases Generates 'pbch_modulator' test vectors.
        %   testvectorGenerationCases(TESTCASE, SSBINDEX, LMAX) generates a 'pbch_modulator'
        %   test vector for the given SSB index SSBINDEX and the given LMAX,
        %   using a random NCellID and a random codeword.

            import ocuduTest.helpers.cellarray2str
            import ocuduTest.helpers.writeUint8File
            import ocuduLib.phy.upper.channel_processors.ssb.ocuduPBCHmodulator
            import ocuduTest.helpers.writeResourceGridEntryFile

            % generate a unique test ID by looking at the number of files generated so far
            testID = testCase.generateTestID;

            % use a unique NCellID and cw for each test
            randomizedTestCase = testCase.randomizeTestvector(testID + 1);
            NCellIDLoc = testCase.NCellID{randomizedTestCase};
            cw = randi([0 1], 864, 1);

            % current fixed parameter values as required by the C code
            numPorts = 1;
            SSBfirstSubcarrier = 0;
            SSBfirstSymbol = 0;
            SSBamplitude = 1;
            SSBports = zeros(numPorts, 1);
            SSBportsStr = cellarray2str({SSBports}, true);

            % write the BCH cw to a binary file
            testCase.saveDataFile('_test_input', testID, @writeUint8File, cw);

            % call the PBCH symbol modulation MATLAB functions
            [modulatedSymbols, symbolIndices] = ocuduPBCHmodulator(cw, NCellIDLoc, SSBindex, Lmax);

            % write each complex symbol and the associated indices to a binary file
            testCase.saveDataFile('_test_output', testID, @writeResourceGridEntryFile, ...
                modulatedSymbols, symbolIndices);

            % generate the test case entry
            testCaseString = testCase.testCaseToString(testID, ...
                {NCellIDLoc, SSBindex, SSBfirstSubcarrier, SSBfirstSymbol, ...
                    SSBamplitude, SSBportsStr}, true, '_test_input', '_test_output');

            % add the test to the file header
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);
        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduPBCHModulatorUnittest
