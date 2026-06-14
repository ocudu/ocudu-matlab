%CheckTests Unit tests for the OCUDU unit test classes.
%   This class, based on the matlab.unittest.TestCase framework, double checks
%   that the classes implementing OCUDU unit tests comply with the required
%   specifications. The test only checks that
%
%   1. the class is an implementation of the main abstract test class;
%   2. all mandatory properties and methods are defined;
%   3. an object of the class can be instantiated correctly;
%   4. the test has the 'testvector' tag;
%   5. an example test vector is generated and stored correctly;
%   6. the mex test (if it exists) runs properly.
%
%   CheckTests Properties (Constant):
%
%   fullBlocks - List of all possible OCUDU blocks.
%
%   CheckTests Properties (TestParameters):
%
%   testName  - The test to check.
%
%   CheckTests Methods (TestParameterDefinition, Static):
%
%   obtainTestNames - Initialize the testName parameter.
%
%   CheckTests Methods (TestClassSetup):
%
%   classSetup - Test setup.
%
%   CheckTests Methods (Test, TestTags = {'matlab code'}):
%
%   runDefinitionTest  - Checks that test classes are properly defined.
%   runVectorTest      - Checks that the testvector functionalities of the test classes
%                        are correct.
%   checkList          - Secondary test to ensure the list of OCUDU blocks is not
%                        over-populated.
%
%   CheckTests Methods (Test, TestTags = {'mex code'})
%
%   runMexTest         - Checks that the testmex functionalities of the test classes
%                        are correct.
%
%   Example
%      runtests('CheckTests')
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef CheckTests < matlab.unittest.TestCase
    properties (TestParameter)
        %Test to check. File name of one of the 'ocuduBlockUnittest' subclasses defining
        %   the tests for an OCUDU block (e.g., 'ocuduModulationMapperUnittest.m').
        testName
    end

    properties (Constant)
        %List of all possible OCUDU blocks. Here, block names include their type
        %   (e.g., 'phy/upper/channel_modulation/modulation_mapper').
        fullBlocks = ocuduTest.listOCUDUblocks('full')
    end

    properties (Hidden)
        %Temporary working directory.
        tmpOutputPath (1, :) char {mustBeFolder(tmpOutputPath)} = '.'

    end % of properties (Hidden)

    methods (TestParameterDefinition, Static)
        function testName = obtainTestNames()
        %obtainTestNames initializes the testName parameter by selecting the proper files
        %   in the ocudu_matlab root directory.

            % Get all .m files in root directory.
            tmp = what('../..');
            testName = tmp.m;

            % Remove files that are not unit tests.
            nFiles = numel(testName);
            deletedFiles = false(nFiles, 1);
            for iFile = 1:nFiles
                if ~startsWith(testName{iFile}, 'ocudu') ...
                        || ~endsWith(testName{iFile}, 'Unittest.m')
                    deletedFiles(iFile) = true;
                end
            end
            testName(deletedFiles) = [];
        end
    end

    methods (TestClassSetup)
        function classSetup(obj)
        %classSetup adds the ocudu_matlab root directory to the MATLAB path.
            import matlab.unittest.fixtures.PathFixture
            import matlab.unittest.fixtures.TemporaryFolderFixture;

            obj.applyFixture(PathFixture('../..'));

            tmp = obj.applyFixture(TemporaryFolderFixture);
            obj.tmpOutputPath = tmp.Folder;
        end
    end

    methods (Test, TestTags = {'matlab code'})
        function runDefinitionTest(obj, testName)
        %runDefinitionTest checks that the test class with the given name is properly defined.

            import matlab.unittest.constraints.IsSubsetOf

            className = testName(1:end-2);
            classMeta = meta.class.fromName(className);
            % Check whether test is inherited from ocuduBlockUnittest.
            supClasses = {classMeta.SuperclassList(:).Name};
            msg = sprintf('Class %s does not inherit from ocuduBlockUnittest.', className);
            obj.assertThat({'ocuduTest.ocuduBlockUnittest'}, IsSubsetOf(supClasses), msg);

            % Check whether the test is abstract.
            msg = sprintf('Class %s is abstract.', className);
            obj.assertFalse(classMeta.Abstract, msg);

            % Check whether test has the mandatory properties.
            props = {classMeta.PropertyList(:).Name};
            [blockFlag, blockIdx] = ismember('ocuduBlock', props);
            [typeFlag, typeIdx] = ismember('ocuduBlockType', props);
            pathFlag = ismember('outputPath', props);
            msg = sprintf('Class %s misses one or more mandatory properties.', className);
            obj.assertTrue(blockFlag && typeFlag && pathFlag, msg);

            % Check whether test has the mandatory methods.
            meths = {classMeta.MethodList(:).Name};
            msg = sprintf('Class %s misses one or more mandatory methods.', className);
            obj.assertThat({'addTestDefinitionToHeaderFile', 'addTestIncludesToHeaderFile'}, ...
                IsSubsetOf(meths), msg);

            % Check whether the block and block type are correct.
            blockVal = classMeta.PropertyList(blockIdx).DefaultValue;
            typeVal = classMeta.PropertyList(typeIdx).DefaultValue;
            msg = sprintf('Class %s refers to invalid block ''%s/%s''.',  ...
                className, typeVal, blockVal);
            obj.assertThat({[typeVal '/' blockVal]}, IsSubsetOf(obj.fullBlocks), msg);
        end % of function runDefinitionTest(obj, testName)

        function runVectorTest(obj, testName)
        %runVectorTest checks that the testvector functionalities of the test class with
        %   the given name are correct.

            import matlab.unittest.constraints.IsFile
            import matlab.unittest.TestSuite
            import matlab.unittest.parameters.Parameter

            className = testName(1:end-2);
            classMeta = meta.class.fromName(className);

            % Get the block name associated to the test.
            props = {classMeta.PropertyList(:).Name};
            [~, blockIdx] = ismember('ocuduBlock', props);
            blockVal = classMeta.PropertyList(blockIdx).DefaultValue;

            % Check whether an object of class testName can be instantiated.
            constructor = str2func(className);
            try
                constructor();
            catch
                msg = sprintf('Cannot instantiate an object of class %s.', className);
                obj.assertFail(msg);
            end

            workDir = fullfile(obj.tmpOutputPath, className);
            extParams = Parameter.fromData('outputPath', {workDir});
            % Check whether the class generates test vectors.
            taggedTV = TestSuite.fromClass(classMeta, 'Tag', 'testvector', ...
                'ExternalParameters', extParams);
            msg = sprintf('Class %s has no tests with tag ''testvector''.',  className);
            obj.assertFalse(isempty(taggedTV), msg);

            % Try to run one of the tests.
            try
                assertSuccess(taggedTV(1).run());
            catch
                msg = sprintf('Class %s cannot run the example test.',  className);
                obj.assertFail(msg);
            end

            % Check whether the header and vector test files are generated.
            fileName = fullfile(workDir, [blockVal '_test_data']);
            msg = sprintf('Class %s cannot create the test vector header file.', className);
            obj.assertThat([fileName, '.h'], IsFile, msg);
            if (hasDataFile(workDir, blockVal))
                msg = sprintf('Class %s cannot create the test vector data file(s).', ...
                    className);
                obj.assertTrue(~isempty(dir([fileName, '*.tar.gz'])), msg);
            end

            % Check whether runOCUDUunittest can run the current test.
            try
                rtest = runOCUDUunittest(blockVal, 'testvector');
            catch
                msg = sprintf('runOCUDUunittest cannot run a test for block %s.', blockVal);
                obj.assertFail(msg);
            end
            msg = sprintf('runOCUDUunittest maps block %s to class %s instead of class %s.', ...
                blockVal, rtest(1).TestClass, className);
            obj.assertMatches(rtest(1).TestClass, className, msg);

        end % of function runVectorTest(obj, testName

        function checkList(obj)
        %checkList checks that all blocks in listOCUDUblocks have a test.

            blocks = ocuduTest.listOCUDUblocks();
            nBlocks = numel(blocks);

            for iBlock = 1:nBlocks
                % Check whether runOCUDUunittest has a test for the current block.
                try
                    [~] = runOCUDUunittest(blocks{iBlock}, 'testvector');
                catch
                    msg = sprintf('runOCUDUunittest does not have a test for block %s.', blocks{iBlock});
                    obj.assertFail(msg);
                end
            end % of for iBlock
        end % of function checkList
    end % of methods (Test, TestTags = {'testvector'})

    methods (Test, TestTags = {'mex code'})
        function runMexTest(obj, testName)
        %runMexTest checks that the testmex functionalities of the test class with
        %   the given name are correct.

            import matlab.unittest.TestSuite
            import matlab.unittest.parameters.Parameter

            className = testName(1:end-2);
            classMeta = meta.class.fromName(className);

            workDir = fullfile(obj.tmpOutputPath, className);
            extParams = Parameter.fromData('outputPath', {workDir});

            % Check whether the class tests a mex wrapper.
            taggedMEX = TestSuite.fromClass(classMeta, 'Tag', 'testmex', ...
                'ExternalParameters', extParams);
            obj.assumeNotEmpty(taggedMEX);

            try
                assertSuccess(taggedMEX(1).run());
            catch
                msg = sprintf('The mex test for %s couldn''t run.', className);
                obj.assertFail(msg);
            end

        end % of function runVectorTest(obj, testName)
    end % of methods (Test, TestTags = {'mex code'})
end % of classdef CheckTests

%hasDataFile Checks whether a test has an associated data file.
function flag = hasDataFile(workDir, blockVal)
    flag = false;

    hFile = fullfile(workDir, [blockVal '_test_data.h']);
    fff = fopen(hFile);
    if (fff == -1)
    % Just in case, we should never get here.
        return;
    end

    pattern = string(blockVal) + wildcardPattern + ".dat";
    line = fgetl(fff);
    while (~flag && ischar(line))
        if contains(line, pattern)
            flag = true;
            continue;
        end
        line = fgetl(fff);
    end

    fclose(fff);
end
