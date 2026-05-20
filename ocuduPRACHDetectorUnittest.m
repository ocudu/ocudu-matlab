%ocuduPRACHDetectorUnittest Unit tests for PRACH detector functions.
%   This class implements unit tests for the PRACH detector functions using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduPRACHDetectorUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduPRACHDetectorUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'prach_detector').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors').
%
%   ocuduPRACHDetectorUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduPRACHDetectorUnittest Properties (TestParameter):
%
%   DuplexMode          - Duplexing mode FDD or TDD.
%   CarrierBandwidth    - Carrier bandwidth in PRB.
%   PreambleFormat      - Generated preamble format.
%   RestrictedSet       - Restricted set type.
%   UseZCZ              - Boolean flag for larger-than-zero zero-correlation zone.
%   RBOffset            - Frequency-domain sequence mapping.
%
%   ocuduPRACHDetectorUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduPRACHDetectorUnittest Methods (TestTags = {'testmex'}):
%
%   mexTest  - Tests the mex wrapper of the OCUDU PRACH detector.
%
%   ocuduPRACHDetectorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduPRACHDetectorUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'prach_detector'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/channel_processors/prach'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'prach_detector' tests will be erased).
        outputPath = {['testPRACHDetector', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Carrier duplexing mode, set to
        %   - FDD for paired spectrum with 15kHz subcarrier spacing, or
        %   - TDD for unpaired spectrum with 30kHz subcarrier spacing.
        %   - TDD-FR2 for unpaired spectrum with 120kHz subcarrier spacing (Frequency Range 2).
        DuplexMode = {'FDD', 'TDD', 'TDD-FR2'}

        %Preamble formats.
        PreambleFormat = {'0', '1', '2', '3', 'A1', 'A2', 'A3', 'B4', 'C0', 'C2'}

        %Zero-correlation zone boolean flag. Set to false for no cyclic shift
        %   and set to true for cyclic shift. The final value of the zero-configuration
        %   zone index is the one given in TS38.141 Table A.6-1.
        UseZCZ = {false, true}

        %Number of receive antennas.
        nAntennas = {1, 2, 4};
    end

    properties (Constant, Hidden)
        %Restricted set type.
        %   Possible values are {'UnrestrictedSet', 'RestrictedSetTypeA', 'RestrictedSetTypeB'}.
        RestrictedSet = 'UnrestrictedSet'
        %Frequency-domain sequence mapping.
        %   Starting resource block (RB) index of the initial uplink bandwidth
        %   part (BWP) relative to carrier resource grid.
        RBOffset = 0
        %Carrier bandwidth in PRB.
        CarrierBandwidth = 52
        %Start preamble index to monitor.
        StartPreambleIndex = 0
        %Number of preamble indices to monitor.
        NofPreamblesIndices = 64
    end % of properties (Constant, Hidden)

    properties (Hidden)
        %Carrier.
        carrier
        %PRACH sequence.
        prach
        %Signal delay (in seconds).
        TrueDelay
    end % of properties (Hidden)

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.

            fprintf(fileID, [...
                '#include "prach_buffer_test_doubles.h"\n'...
                '#include "ocudu/phy/upper/channel_processors/prach/prach_detector.h"\n'...
                '#include "ocudu/support/file_tensor.h"\n'...
                ]);
        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.

            fprintf(fileID, [...
                'using sequence_data_type = file_tensor<static_cast<unsigned>(prach_buffer_tensor::dims::count), cf_t, prach_buffer_tensor::dims>;\n'...
                '\n'...
                'struct context_t {\n'...
                '  prach_detector::configuration config;\n'...
                '  phy_time_unit                 true_delay;\n' ...
                '  prach_detection_result        result;\n'...
                '};\n'...
                '\n'...
                'struct test_case_t {\n'...
                '  context_t context;\n'...
                '  sequence_data_type symbols;\n'...
                '};\n'...
                ]);
        end
    end % of methods (Access = protected)

    methods (TestClassSetup)
        function silenceWarnings(obj)
            warn = warning('query', 'ocudu_matlab:ocuduPRACHdetector');
            warning('off', 'ocudu_matlab:ocuduPRACHdetector');

            obj.addTeardown(@warning, warn.state, 'ocudu_matlab:ocuduPRACHdetector');
        end
    end % of methods (TestClassSetup)

    methods (Access = private)
        function setupsimulation(obj, DuplexMode, PreambleFormat, UseZCZ)
        % Sets secondary simulation variables.

            import ocuduLib.phy.helpers.ocuduConfigurePRACH

            obj.assumeTrue(~strcmp(DuplexMode, 'TDD-FR2') || ismember(PreambleFormat, {'A1', 'B4', 'C0'}), ...
                'Only short formats A1, B4 and C0 are currently allowed in FR2.');

            restrictedSet = obj.RestrictedSet;
            rbOffset = obj.RBOffset;

            % Select PRACH random parameters.
            sequenceIndex = randi([0, 1023], 1, 1);
            preambleIndex = randi([0, 63], 1, 1);

            % Generate carrier configuration.
            obj.carrier = nrCarrierConfig;
            obj.carrier.CyclicPrefix = 'normal';
            obj.carrier.NSizeGrid = obj.CarrierBandwidth;

            frequencyRange = 'FR1';

            % Set parameters that depend on the duplex mode.
            switch DuplexMode
                case 'FDD'
                    obj.carrier.SubcarrierSpacing = 15;
                case 'TDD'
                    obj.carrier.SubcarrierSpacing = 30;
                case 'TDD-FR2'
                    obj.carrier.SubcarrierSpacing = 120;
                    frequencyRange = 'FR2';
                otherwise
                    error('Invalid duplex mode %s', obj.DuplexMode);
            end

            zeroCorrelationZone = 0;

            % Select zero correlation zone according to TS38.104 Table A.6-1.
            if UseZCZ
                if strlength(PreambleFormat) == 1
                    zeroCorrelationZone = 1;
                else
                    if strcmp(DuplexMode, 'FDD') 
                        zeroCorrelationZone = 11;
                    else
                        zeroCorrelationZone = 14;
                    end
                end
            end

            % Generate PRACH configuration.
            obj.prach = ocuduConfigurePRACH(PreambleFormat, ...
                FrequencyRange=frequencyRange, ...
                DuplexMode=DuplexMode(1:3), ...
                SubcarrierSpacing=obj.carrier.SubcarrierSpacing, ...
                SequenceIndex=sequenceIndex, ...
                PreambleIndex=preambleIndex, ...
                RestrictedSet=restrictedSet, ...
                ZeroCorrelationZone=zeroCorrelationZone, ...
                RBOffset=rbOffset ...
                );
        end % of function setupsimulation(obj, PreambleFormat, UseZCZ)

        function grid = generatePRACH(obj, nAntennas) 
            import ocuduLib.phy.upper.channel_processors.ocuduPRACHgenerator
            import ocuduLib.phy.lower.modulation.ocuduPRACHdemodulator

            % Generate waveform.
            [waveform, gridset, info] = ocuduPRACHgenerator(obj.carrier, obj.prach);
            obj.prach.NPRACHSlot = info.NPRACHSlot;

            carrOFDMInfo = nrOFDMInfo(obj.carrier);

            % The maximum delay is 1/128 of the PRACH duration (half of the
            % smallest zero-correlation zone).
            obj.TrueDelay = (0.1 + 0.9 * rand) / obj.prach.SubcarrierSpacing / 1000 / 128;
            delaySamples = floor(obj.TrueDelay * gridset.Info.SampleRate);

            channelMatrix = ones(1, nAntennas);
            rxWaveform = [zeros(delaySamples, 1); waveform] * channelMatrix;

            % Add some noise.
            snr = 0; % dB
            noiseStdDev = 10 ^ (-snr / 20) / sqrt(nAntennas * carrOFDMInfo.Nfft);

            waveformSize = size(rxWaveform);
            normNoise = (randn(waveformSize) + 1i * randn(waveformSize)) / sqrt(2);
            rxWaveform = rxWaveform + (noiseStdDev * normNoise);

            % Demodulate the PRACH signal.
            grid = ocuduPRACHdemodulator(obj.carrier, obj.prach, gridset.Info, rxWaveform, info);

        end % of function grid = generatePRACH(nAntennas) 
    end % of methods (Access = Private)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(obj, DuplexMode, PreambleFormat, UseZCZ, nAntennas)
        %testvectorGenerationCases Generates a test vector for the given
        %   DuplexMode, CarrierBandwidth, PreambleFormat, RestrictedSet,
        %   UseZCZ and RBOffset. The parameters SequenceIndex
        %   and PreambleIndex are generated randomly.

            import ocuduTest.helpers.writeComplexFloatFile

            % Generate a unique test ID.
            TestID = obj.generateTestID;

            % Configure the test.
            obj.setupsimulation(DuplexMode, PreambleFormat, UseZCZ);

            % Generate PRACH grid.
            grid = obj.generatePRACH(nAntennas);

            [ix, delays, normMetrics, preamblePowers, rssi] = ocuduLib.phy.upper.channel_processors.ocuduPRACHdetector(obj.carrier, obj.prach, grid);
            pp = obj.prach.PreambleIndex + 1;
            obj.assertTrue(ix(pp), sprintf('Transmitted preamble %d not detected.', pp - 1));
            if ~strcmp(DuplexMode, 'TDD-FR2')
                obj.assertEqual(10 * log10(preamblePowers(pp)), 0, 'Wrong estimated preamble power.', AbsTol=3);
            end

            % The number of sequence replicas in a PRACH preamble is, in general, equal to the number of
            % OFDM symbols spanned by the PRACH occasion.
            L = obj.prach.PRACHDuration;

            % For PRACH Format C2, however, the PRACH duration is inflated by two symbols to account
            % for the long CP (one entire sequence) and the guard band. (MATLAB already deals with
            % the issue in case of Format C0.)
            if strcmp(obj.prach.Format, 'C2')
                L = L - 2;
            end

            % Reshape grid with PRACH symbols.
            grid = reshape(grid, obj.prach.LRA, L, nAntennas);

            % Write the generated PRACH sequence into a binary file.
            obj.saveDataFile('_test_input', TestID, ...
                @writeComplexFloatFile, grid);

            % Prepare the test header file.
            ocuduPRACHFormat = sprintf('to_prach_format_type("%s")', obj.prach.Format);

            switch obj.prach.RestrictedSet
                case 'UnrestrictedSet'
                    ocuduRestrictedSet = 'restricted_set_config::UNRESTRICTED';
                case 'RestrictedSetTypeA'
                    ocuduRestrictedSet = 'restricted_set_config::TYPE_A';
                case 'RestrictedSetTypeB'
                    ocuduRestrictedSet = 'restricted_set_config::TYPE_B';
                otherwise
                    error('Invalid restricted set %s', ojb.prach.RestrictedSet);
            end

            prachSCSString = sprintf('to_ra_subcarrier_spacing("%fkHz")', ...
                obj.prach.SubcarrierSpacing);

            % PRACH detector configuration.
            ocuduPRACHDetectorConfig = {...
                obj.prach.SequenceIndex, ...        % root_sequence_index
                ocuduPRACHFormat, ...               % format
                ocuduRestrictedSet, ...             % restricted_set
                obj.prach.ZeroCorrelationZone, ...  % zero_correlation_zone
                obj.StartPreambleIndex, ...         % start_preamble_index
                obj.NofPreamblesIndices, ...        % nof_preamble_indices
                prachSCSString, ...                 % ra_scs
                nAntennas, ...                      % nof_rx_ports
                };

            delayString = sprintf('phy_time_unit::from_seconds(%g)', delays(pp) * 1e-6);
            ocuduPreambleIndication = {...
                obj.prach.PreambleIndex, ...            % preamble_index
                delayString, ...                        % time_advance
                normMetrics(pp), ...                    % detection_metric
                10 * log10(preamblePowers(pp)), ...     % preamble_power_dB
                };

            ocuduPrachDetectionResult = {...
                rssi, ...                               % rssi_dB
                'phy_time_unit::from_seconds(0.0)', ... % time_resolution
                'phy_time_unit::from_seconds(0.0)', ... % time_advance_max
                {ocuduPreambleIndication}, ...          % preambles
                };

            truedelayString = sprintf('phy_time_unit::from_seconds(%g)', obj.TrueDelay);
            ocuduContext = {
                ocuduPRACHDetectorConfig, ...  % config
                truedelayString, ...           % true PRACH delay
                ocuduPrachDetectionResult, ... % result
                };

            prachGridDims = {...
                size(grid, 1), ... % Number of RE.
                size(grid, 2), ... % Number of symbols.
                1, ...             % Number of frequency-domain occasions.
                1, ...             % Number of time-domain occasions.
                size(grid, 3), ... % Number of ports.
                };

            % Generate the test case entry.
            testCaseString = obj.testCaseToString(TestID, ...
                ocuduContext, true, {'_test_input', prachGridDims});

            % Add the test to the file header.
            obj.addTestToHeaderFile(obj.headerFileID, testCaseString);

        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})

    methods (Test, TestTags = {'testmex'})
        function mexTest(obj, DuplexMode, PreambleFormat, UseZCZ, nAntennas)
            %mexTest  Tests the mex wrapper of the OCUDU PRACH detector.
            %   mexTest(OBJ, DUPLEXMODE, CARRIERBANDWIDTH, PREAMBLEFORMAT,
            %   RESTRICTEDSET, ZEROCORRELATIONZONE, RBOFFSET) runs a short
            %   simulation with a UL transmission using a carrier with duplex
            %   mode DUPLEXMODE and a bandiwth of CARRIERBANDWITH PRBs. This
            %   transmision comprises a PRACH signal using preamble format
            %   PREAMBLEFORMAT, restricted set configuration RESTRICTEDSET,
            %   cyclic shift index configuration ZEROCORRELATIONINDEX and a RB
            %   offset RBOFFSET. The PRACH transmission is demodulated in
            %   MATLAB and PRACH detection is then performed using the mex
            %   wrapper of the OCUDU C++ component. The test is considered
            %   as passed if the detected PRACH is equal to the transmitted one.

            import ocuduMEX.phy.ocuduPRACHDetector

            % Configure the test.
            obj.setupsimulation(DuplexMode, PreambleFormat, UseZCZ);

            % Configure the OCUDU PRACH detector mex.
            PRACHDetector = ocuduPRACHDetector();

            nRuns = 10;
            nDetections = 0;
            nPerfectDetections = 0;
            for iRun = 1:nRuns
                % Generate PRACH grid.
                PRACHGrid = obj.generatePRACH(nAntennas);

                % The number of sequence replicas in a PRACH preamble is, in general, equal to the number of
                % OFDM symbols spanned by the PRACH occasion.
                L = obj.prach.PRACHDuration;

                % For PRACH Format C2, however, the PRACH duration is inflated by two symbols to account
                % for the long CP (one entire sequence) and the guard band. (MATLAB already deals with
                % the issue in case of Format C0.)
                if strcmp(obj.prach.Format, 'C2')
                    L = L - 2;
                end

                % Reshape grid with PRACH symbols.
                PRACHGrid = reshape(PRACHGrid, obj.prach.LRA, L, nAntennas);

                try
                    % Run the PRACH detector.
                    PRACHdetectionResult = PRACHDetector(obj.prach, PRACHGrid);
                catch exception
                    obj.assertTrue(strncmp(exception.message, 'Invalid configuration', 21), 'Unexpected MEX error.');
                    obj.assumeFail(['MEX unsupported configuration:', exception.message(23:end)]);
                end


                maskDetected = (PRACHdetectionResult.PreambleIndices == obj.prach.PreambleIndex);

                % If we only detect the transmitted preamble...
                if (sum(maskDetected) == 1)
                    nDetections = nDetections + 1;

                    % Now check if it's a perfect detection.
                    timeAdvanceDetected = PRACHdetectionResult.TimeAdvance(maskDetected);
                    if (abs(timeAdvanceDetected - obj.TrueDelay) <= 1.0e-6)
                        nPerfectDetections = nPerfectDetections + 1;
                    end
                end
            end
            % Not a performance test: set very loose detection probability requirements.
            obj.assertGreaterThan(nDetections, nRuns * 0.7, 'Detection probability too low.');
            obj.assertGreaterThan(nPerfectDetections, nRuns * 0.6, 'Perfect detection probability too low.');
        end % of function mextest
    end % of methods (Test, TestTags = {'testmex'})
end % of classdef ocuduPUSCHDecoderUnittest
