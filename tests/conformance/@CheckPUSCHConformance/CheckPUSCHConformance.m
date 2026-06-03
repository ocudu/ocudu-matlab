%CheckPUSCHConformance Battery of conformance tests for the PUSCH.
%   This class, based on the matlab.unittest.TestCase framework, performs a battery
%   of conformance tests on the PUSCH. Specifically, the tests are a subset of
%   those described in TS38.104 Section 8.2 and TS38.141-1 Section 8.2 (for FR1),
%   in TS38.104 Section 11.2.2 and TS38.141-2 Section 8.2 (for FR2), plus some
%   custom tests. The tests consist in running a short simulation and ensuring
%   that the estimated throughput is above the required value.
%
%   CheckPUSCHConformance Properties (Constant):
%
%   FRC  - Fixed Reference Channels.
%
%   CheckPUSCHConformance Properties (TestParameter):
%
%   TestConfigTable8_2_1_2_1     - PUSCH test configurations - Type A, 5 MHz channel bandwidth, 15 kHz SCS.
%   TestConfigTable8_2_1_2_2     - PUSCH test configurations - Type A, 10 MHz channel bandwidth, 15 kHz SCS.
%   TestConfigTable8_2_1_2_3     - PUSCH test configurations - Type A, 20 MHz channel bandwidth, 15 kHz SCS.
%   TestConfigTable8_2_1_2_4     - PUSCH test configurations - Type A, 10 MHz channel bandwidth, 30 kHz SCS.
%   TestConfigTable8_2_1_2_5     - PUSCH test configurations - Type A, 20 MHz channel bandwidth, 30 kHz SCS.
%   TestConfigTable8_2_1_2_6     - PUSCH test configurations - Type A, 40 MHz channel bandwidth, 30 kHz SCS.
%   TestConfigTable8_2_1_2_7     - PUSCH test configurations - Type A, 100 MHz channel bandwidth, 30 kHz SCS.
%   TestConfigTable8_2_2_2_x     - PUSCH test configurations - Type A, transform precoding enabled.
%   TestConfigTable11_2_2_1_2_3  - PUSCH test configurations - Type B, 50 MHz channel bandwidth, 120 kHz SCS.
%   TestConfigCustom             - PUSCH test configurations - Type A, custom cases.
%   NumLayers                    - Number of transmission layers (1 to 4, only for custom tests).
%
%   CheckPUSCHConformance Methods (Test, TestTags = {'conformance'}), each running
%      a the tests from the corresponding configuration table:
%
%   checkPUSCHconformanceTable8_2_1_2_1
%   checkPUSCHconformanceTable8_2_1_2_2
%   checkPUSCHconformanceTable8_2_1_2_3
%   checkPUSCHconformanceTable8_2_1_2_4
%   checkPUSCHconformanceTable8_2_1_2_5
%   checkPUSCHconformanceTable8_2_1_2_6
%   checkPUSCHconformanceTable8_2_1_2_7
%   checkPUSCHconformanceTable8_2_2_2_x
%   checkPUSCHconformanceTable11_2_2_1_2_3
%   checkPUSCHconformanceCustom
%
%   Example
%      runtests('CheckPUSCHConformance')
%
%   See also matlab.unittest, PUSCHBLER.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef CheckPUSCHConformance < matlab.unittest.TestCase
    properties (Constant)
        %Fixed Reference Channels.
        %   Dictionary of parameters of the reference measurement channels. Keys
        %   parameters are taken from TS38.104 Appendix A.
        FRC = CheckPUSCHConformance.createFRC()
    end % of properties (Constant)

    properties (Constant, Hidden)
        %Folder for storing the test results in csv format.
        OutputFolder = 'conformanceResults'
        %File for storing the results in csv format.
        OutputFile = fullfile(pwd, CheckPUSCHConformance.OutputFolder, ['conformancePUSCH', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss')), '.csv'])
    end % of properties (Constant, Hidden)

    properties (TestParameter)
        %PUSCH test configurations - Type A, 5 MHz channel bandwidth, 15 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 and V19.0.0 Table 8.2.1.2-1.
        TestConfigTable8_2_1_2_1 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_1()
        %PUSCH test configurations - Type A, 10 MHz channel bandwidth, 15 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Table 8.2.1.2-2.
        TestConfigTable8_2_1_2_2 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_2()
        %PUSCH test configurations - Type A, 20 MHz channel bandwidth, 15 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Table 8.2.1.2-3.
        TestConfigTable8_2_1_2_3 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_3()
        %PUSCH test configurations - Type A, 10 MHz channel bandwidth, 30 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 and V19.0.0 Table 8.2.1.2-4.
        TestConfigTable8_2_1_2_4 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_4()
        %PUSCH test configurations - Type A, 20 MHz channel bandwidth, 30 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Table 8.2.1.2-5.
        TestConfigTable8_2_1_2_5 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_5()
        %PUSCH test configurations - Type A, 40 MHz channel bandwidth, 30 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Table 8.2.1.2-6.
        TestConfigTable8_2_1_2_6 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_6()
        %PUSCH test configurations - Type A, 100 MHz channel bandwidth, 30 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 and V19.0.0 Table 8.2.1.2-7.
        TestConfigTable8_2_1_2_7 = CheckPUSCHConformance.createTestConfigTable8_2_1_2_7()
        %PUSCH test configurations - Type A, transform precoding enabled.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Tables 8.2.2.2-1 and 8.2.2.2-2.
        TestConfigTable8_2_2_2_x = CheckPUSCHConformance.createTestConfigTable8_2_2_2_x()
        %PUSCH test configurations - Type B, 50 MHz channel bandwidth, 120 kHz SCS.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        %   Cases from TS38.104 V15.19.0 Table 11.2.2.1.2-3.
        TestConfigTable11_2_2_1_2_3 = CheckPUSCHConformance.createTestConfigTable11_2_2_1_2_3()
        %PUSCH test configurations - Type A, custom cases.
        %   Defines, for each test, the DelayProfile, the DelaySpread and the
        %   MaximumDopplerShift of the channel, the number of Rx antennas NRxAnts,
        %   the FRC and the target SNR.
        TestConfigCustom = CheckPUSCHConformance.createTestConfigCustom()
        %Number of transmission layers (only for custom tests).
        NumLayers = {1, 2, 3, 4}
    end % of properties (TestParameter)

    methods (TestClassSetup)
        function preparecsv(obj)
        %Creates a csv file for storing the results of all tests.

            if ~exist(obj.OutputFolder, 'dir')
                mkdir(obj.OutputFolder);
            end
            fff = fopen(obj.OutputFile, 'w');

            % Write file header.
            fprintf(fff, '#datatype measurement,tag,tag,double,dateTime:RFC3339\n');
            fprintf(fff, '#default,,,\n');
            fprintf(fff, 'm,suite,test,value,time\n');

            fclose(fff);
        end % of function preparecsv(obj)
    end % of methods (TestClassSetup)

    methods (Test, TestTags = {'conformance'})
        function checkPUSCHconformanceTable8_2_1_2_1(obj, TestConfigTable8_2_1_2_1)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-1.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_1);
        end

        function checkPUSCHconformanceTable8_2_1_2_2(obj, TestConfigTable8_2_1_2_2)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-2.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_2);
        end

        function checkPUSCHconformanceTable8_2_1_2_3(obj, TestConfigTable8_2_1_2_3)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-3.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_3);
        end

        function checkPUSCHconformanceTable8_2_1_2_4(obj, TestConfigTable8_2_1_2_4)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-4.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_4);
        end

        function checkPUSCHconformanceTable8_2_1_2_5(obj, TestConfigTable8_2_1_2_5)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-5.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_5);
        end

        function checkPUSCHconformanceTable8_2_1_2_6(obj, TestConfigTable8_2_1_2_6)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-6.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_6);
        end

        function checkPUSCHconformanceTable8_2_1_2_7(obj, TestConfigTable8_2_1_2_7)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 8.2.1.2-7.

            checkPUSCHconformance(obj, TestConfigTable8_2_1_2_7);
        end

        function checkPUSCHconformanceTable8_2_2_2_x(obj, TestConfigTable8_2_2_2_x)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Tables 8.2.2.2-1 and 8.2.2.2-2.

            checkPUSCHconformance(obj, TestConfigTable8_2_2_2_x);
        end

        function checkPUSCHconformanceTable11_2_2_1_2_3(obj, TestConfigTable11_2_2_1_2_3)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Tests specified in TS38.104 V15.19.0 Table 11.2.2.1.2-3.

            checkPUSCHconformance(obj, TestConfigTable11_2_2_1_2_3);
        end

        function checkPUSCHconformanceCustom(obj, TestConfigCustom, NumLayers)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.
        %   Custom test cases.

            TestConfigCustom.NTxAnts = NumLayers;
            if NumLayers < 3
                TestConfigCustom.NRxAnts = NumLayers;
            else
                TestConfigCustom.NRxAnts = 4;
            end

            if NumLayers == 1
                strlayer = ' 1 layer';
            else
                strlayer = sprintf(' %d layers', NumLayers);
            end
            TestConfigCustom.Name = [TestConfigCustom.Name strlayer];

            checkPUSCHconformance(obj, TestConfigCustom);
        end
    end % of methods (Test, TestTags = {'conformance'})

    methods (Access=private)
        function checkPUSCHconformance(obj, TestConfig)
        %Verifies that the target throughput is achieved for the given PUSCH configuration.

            import matlab.unittest.fixtures.CurrentFolderFixture
            import matlab.unittest.constraints.IsFile

            % Avoid multi-layer tests if not supported by the MEX functions.
            % Note: The TS38.104 specifies the number of layers to be equal to the number
            % of Tx antennas.
            maxLayers = 4;
            obj.assumeGreaterThanOrEqual(maxLayers, TestConfig.NTxAnts, ...
                sprintf('The current MEX version does not support more than %d layers, requested %d.', maxLayers, TestConfig.NTxAnts));

            obj.applyFixture(CurrentFolderFixture('../../apps/simulators/PUSCHBLER'));

            try
                pp = PUSCHBLER;
            catch ME
                obj.assertFail(['Could not create a PUSCHBLER object because of exception: ', ...
                    ME.message]);
            end

            obj.assertClass(pp, 'PUSCHBLER', 'The created object is not a PUSCHBLER object.');

            obj.assertThat('../../../+ocuduMEX/+phy/@ocuduPUSCHDecoder/pusch_decoder_mex.mexa64', IsFile, ...
                'Could not find PUSCH decoder mex executable.');
            obj.assertThat('../../../+ocuduMEX/+phy/@ocuduPUSCHDemodulator/pusch_demodulator_mex.mexa64', IsFile, ...
                'Could not find PUSCH demodulator mex executable.');
            obj.assertThat('../../../+ocuduMEX/+phy/@ocuduMultiPortChannelEstimator/multiport_channel_estimator_mex.mexa64', IsFile, ...
                'Could not find channel estimator mex executable.');

            % Avoid meaningless warnings.
            puschblerwarn = warning('query', 'MATLAB:system:nonRelevantProperty');
            warning('off', 'MATLAB:system:nonRelevantProperty');

            % Simulation set-up.
            frc = obj.FRC(TestConfig.FRC);
            pp.SubcarrierSpacing = frc.SubcarrierSpacing;
            if contains(TestConfig.Name, 'Custom')
                pp.NSizeGrid = 273;
                pp.CarrierFrequencyOffset = 600;
                pp.OCUDUCompensateCFO = true;
            else
                pp.NSizeGrid = frc.PRBSet(end) + 1;
                pp.CarrierFrequencyOffset = 0;
                pp.OCUDUCompensateCFO = false;
            end
            pp.PRBSet = frc.PRBSet;
            pp.MCSTable = 'custom';
            pp.Modulation = frc.Modulation;
            pp.TargetCodeRate = frc.TargetCodeRate;
            pp.NTxAnts = TestConfig.NTxAnts;
            pp.NRxAnts = TestConfig.NRxAnts;
            pp.NumLayers = TestConfig.NTxAnts;
            pp.DelayProfile = TestConfig.DelayProfile;
            if isfield(TestConfig, 'DelaySpread')
                pp.DelaySpread = TestConfig.DelaySpread;
            end
            if (frc.SubcarrierSpacing ~= 120)
                pp.MappingType = 'A';
                pp.SymbolAllocation = [0, 14];
            else
                pp.MappingType = 'B';
                pp.SymbolAllocation = [0, 10];
            end
            if isfield(TestConfig, 'DMRSAdditionalPosition')
                pp.DMRSAdditionalPosition = TestConfig.DMRSAdditionalPosition;
            else
                pp.DMRSAdditionalPosition = 1;
            end
            pp.MaximumDopplerShift = TestConfig.MaximumDopplerShift;
            pp.FadingTimeEvolution = 'Slot independent';
            pp.PerfectChannelEstimator = false;
            pp.EnableHARQ = true;
            pp.ImplementationType = 'ocudu';
            pp.OCUDUEstimatorType = 'MEX';
            pp.OCUDUInterpolation = 'interpolate';
            pp.OCUDUSmoothing = 'filter';
            pp.OCUDUEqualizerType = 'MMSE';
            pp.QuickSimulation = false;

            if ~contains(TestConfig.Name, 'Table 8.2.2.2')
                pp.TransformPrecoding = false;
            else
                pp.TransformPrecoding = true;
            end

            % Restore warnings.
            warning(puschblerwarn);

            mu = log2(frc.SubcarrierSpacing / 15);
            nFrames = 480 / 2^mu;
            try
                pp(TestConfig.SNR, nFrames);
            catch ME
                obj.assertFail(['PUSCHBLER simulation failed with error: ', ME.message]);
            end

            tp = pp.ThroughputOCUDU / pp.MaxThroughput;

            % Export throughput in csv format to be imported in grafana.
            if (maxLayers == 1)
                fullName = [TestConfig.Name, ' - project'];
            else
                fullName = [TestConfig.Name, ' - enterprise'];
            end
            writecsv(obj, fullName, tp * 100);

            obj.verifyGreaterThanOrEqual(tp, 0.75, 'WARNING: Throughput should be at least 70% for TS cases.');
            obj.assertGreaterThan(tp, 0.70, 'ERROR: Throughput for a TS case is below the hard acceptance threshold of 70%.');

        end % of function checkPUSCHconformance(obj, TestConfig)

        function writecsv(obj, casename, tp)
        %Writes the test entry in the csv file.

            fff = fopen(obj.OutputFile, 'a');
            currTime = getenv("CI_PIPELINE_CREATED_AT");
            if isempty(currTime)
                currTime = char(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z'''));
            end
            fprintf(fff, 'Throughput,matlab/PUSCH conformance,%s,%.3f,%s\n', casename, tp, currTime);

            fclose(fff);
        end % of function writecsv(obj)
    end % of methods (Access=private)

    methods (Access=private, Static)
        % Signatures of function defined in dedicated files.
        frcdictionary = createFRC()
        testConfig = createTestConfigTable8_2_1_2_1()
        testConfig = createTestConfigTable8_2_1_2_2()
        testConfig = createTestConfigTable8_2_1_2_3()
        testConfig = createTestConfigTable8_2_1_2_4()
        testConfig = createTestConfigTable8_2_1_2_5()
        testConfig = createTestConfigTable8_2_1_2_6()
        testConfig = createTestConfigTable8_2_1_2_7()
        testConfig = createTestConfigTable8_2_2_2_x()
        testConfig = createTestConfigTable11_2_2_1_2_3()
        testConfig = createTestConfigCustom()
    end % of methods (Access=private, Static)
end % of classdef CheckConformance < matlab.unittest.TestCase
