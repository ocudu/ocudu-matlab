%ocuduChEstimatorUnittest Unit tests for the port channel estimator.
%   This class implements unit tests for the port channel estimator functions using
%   the matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduChEstimatorUnittest
%   and then running all the tests with
%      testResults = testCase.run
%
%   ocuduChEstimatorUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'port_channel_estimator').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/signal_processors/channel_estimator').
%
%   ocuduChEstimatorUnittest Properties (ClassSetupParameter):
%
%   outputPath  - Path to the folder where the test results are stored.
%
%   ocuduChEstimatorUnittest Properties (TestParameter):
%
%   Configuration     - Description of the PHY UL transmission requiring channel estimation.
%   SubcarrierSpacing - Subcarrier spacing in kilohertz.
%   NumLayers         - Number of transmission layers.
%   FrequencyHopping  - Frequency hopping type.
%   CarrierOffset     - Carrier frequency offset, as a fraction of the subcarrier spacing.
%
%   ocuduChEstimatorUnittest Methods:
%
%   characterize  - Draws the empirical MSE performance curve of the estimator.
%
%   ocuduChEstimatorUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduChEstimatorUnittest Methods (TestTags = {'testmex'}):
%
%   compareMex - Compares mex results with those from the reference estimator.
%
%   ocuduChEstimatorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduChEstimatorUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'port_channel_estimator'

        %Type of the tested block, including layers.
        ocuduBlockType = 'phy/upper/signal_processors/channel_estimator'
    end % of properties (Constant)

    properties (Hidden, Constant)
        % Number of resource elements in a RB and OFDM symbols in a slot.
        NRE = 12
        nSymbolsSlot = 14
    end % of properties (Hidden, Constant)

    properties (Hidden, SetAccess=private)
        % Fix BWP size and start as well as the frame number, since they
        % are irrelevant for the test.
        NSizeBWP = 51
        NStartBWP = 1
        NSizeGrid = 52 % ocuduChEstimatorUnittest.NSizeBWP + ocuduChEstimatorUnittest.NStartBWP
    end % of properties (Hidden, SetAccess=private)

    properties (ClassSetupParameter)
        %Path to results folder (old 'port_channel_estimator' tests will be erased).
        outputPath = {['testChEstimator', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Configuration.
        %   A configuration structure array with fields:
        %   Channel                 - PHY UL channel requiring channel estimation ('PUSCH', 'PUCCHF2', 'PUCCHF3F4')
        %   NumPRBs                 - Number of allocated PRBs (0...51)
        %   SymbolAllocation        - A two-element array denoting the first allocated OFDM symbol (0...13)
        %                             and the number of allocated OFDM symbols (1...14).
        %   NumLayers               - Number of transmission layers (1...4), only for 'PUSCH'.
        %   DMRSTypeAPosition       - Position of the first DM-RS symbol (2, 3), only for 'PUSCH'.
        %   DMRSAdditionalPosition  - Maximum number of DM-RS additional positions (0...3), only for 'PUSCH'.
        %   FrequencyHopping        - Frequency hopping type ('neither', 'intraSlot').
        %   Smoothing               - The frequency-domain smoothing strategy to be used with the
        %                             current configuration ('filter', 'mean', 'none').
        %   CFOcompensate           - A boolean flag denoting whether the channel estimator should
        %                             compensate (true) or not (false) the CFO.
        Configuration = generateTestConfig()

        %Subcarrier spacing in kHz.
        SubcarrierSpacing = {15, 30}

        %Carrier frequency offset, as a fraction of the subcarrier spacing.
        CarrierOffset = {0, 0.007, -0.013, 0.027}
    end % of properties (TestParameter)

    properties (Hidden)
        %OFDM symbol in which the second hop starts (if any).
        secondHop
        %Mask of OFDM symbols carrying DM-RS.
        DMRSsymbols
        %Mask of REs carrying DM-RS (relative to one PRB and one OFDM symbol).
        DMRSREmask
    end % of properties (Hidden)

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile(OBJ, FILEID) adds include directives to
        %   the header file pointed by FILEID, which describes the test vectors.
            fprintf(fileID, '#include "resource_grid_test_doubles.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/signal_processors/channel_estimator/port_channel_estimator.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/signal_processors/channel_estimator/port_channel_estimator_parameters.h"\n');
            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
            fprintf(fileID, '#include <optional>\n');

        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDefinitionToHeaderFile(OBJ, FILEID) adds test details (e.g., type
        %   and variable declarations) to the header file pointed by FILEID, which
        %   describes the test vectors.
            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, '  port_channel_estimator::configuration                   cfg;\n');
            fprintf(fileID, '  port_channel_estimator_fd_smoothing_strategy            smoothing;\n');
            fprintf(fileID, '  bool                                                    compensate_cfo = false;\n');
            fprintf(fileID, '  unsigned                                                grid_size_prbs = 0;\n');
            fprintf(fileID, '  float                                                   rsrp           = 0;\n');
            fprintf(fileID, '  float                                                   epre           = 0;\n');
            fprintf(fileID, '  float                                                   snr_true       = 0;\n');
            fprintf(fileID, '  float                                                   snr_est        = 0;\n');
            fprintf(fileID, '  float                                                   noise_var_est  = 0;\n');
            fprintf(fileID, '  float                                                   ta_us          = 0;\n');
            fprintf(fileID, '  float                                                   cfo_true_Hz    = 0;\n');
            fprintf(fileID, '  std::optional<float>                                    cfo_est_Hz     = 0;\n');
            fprintf(fileID, '  file_vector<resource_grid_reader_spy::expected_entry_t> grid;\n');
            fprintf(fileID, '  file_vector<cf_t>                                       pilots;\n');
            fprintf(fileID, '  file_vector<resource_grid_reader_spy::expected_entry_t> estimates;\n');
            fprintf(fileID, '};\n');
        end
    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(obj, Configuration, SubcarrierSpacing, CarrierOffset)
        %testvectorGenerationCases - Generates a test vector according to the provided
        %   CONFIGURATION, SUBCARRIERSPACING and CARRIEROFFSET.

            import ocuduTest.helpers.writeResourceGridEntryFile
            import ocuduTest.helpers.writeComplexFloatFile

            [fullConfig, channel, receivedRG, results] = obj.configureAndMatlab(Configuration, ...
                SubcarrierSpacing, CarrierOffset);

            % Generate a unique test ID.
            testID = obj.generateTestID;

            channelEst = results.ChannelEst;
            noiseEst = results.NoiseEst;
            rsrp = results.RSRP;
            epre = results.EPRE;
            timeAlignment = results.TimeAlignment;
            cfoEst = results.CFO;

            % TODO: The ratio of the two quantities below should give a metric that allows us
            % to decide whether pilots were sent or not. However, it should be normalized
            % and it's a bit tricky.
            % detectMetricNum = detectMetricNum / nDMRSsymbols;
            % detectMetricDen = noiseEst;
            % detectionMetric = detectMetricNum / detectMetricDen;

            SNR = channel.SNR;
            channelRG = channel.RG;
            noiseVar = 10^(-SNR/10);
            channelDelay = channel.Delay;
            cfo = channel.CFO;

            betaDMRS = fullConfig.BetaDMRS;
            fftSize = fullConfig.FFTSize;

            if isfield(Configuration, 'NumLayers')
                nLayers = Configuration.NumLayers;
            else
                nLayers = 1;
            end
            snrEst = rsrp * nLayers / betaDMRS^2 / noiseEst;

            % A few very loose checks, just to ensure we are not completely out of place.
            if (Configuration.NumPRBs > 2)
                chEstIdx = (channelEst ~= 0);
                isCFOmeaningful = (sum(fullConfig.Hop1.DMRSsymbols) > 1) && (sum(fullConfig.Hop2.DMRSsymbols) > 1);
                if ((CarrierOffset == 0) || isCFOmeaningful)
                    obj.assertEqual(channelEst(chEstIdx), channelRG(chEstIdx), "Wrong channel coefficients.", RelTol = 0.4);
                end
                obj.assertEqual(noiseEst, noiseVar, "Wrong noise variance.", RelTol = 1.2 * nLayers);
                obj.assertEqual(snrEst, 10^(SNR/10), "Wrong SNR.", RelTol = 2.5);
                obj.assertEqual(timeAlignment, channelDelay / fftSize / SubcarrierSpacing / 1000, ...
                    "Wrong time alignment.", AbsTol = 2e-7);
                cfoHz = cfo * SubcarrierSpacing * 1000;
                if (~strcmp(Configuration.Channel, 'PUCCHF2') && ~isempty(cfoEst) && (abs(cfoEst - cfoHz) > 50) && ((cfoHz == 0) || abs(cfoEst / cfoHz - 1) > 0.7))
                    warning('ocudu_matlab:ocuduChEstimatorUnittest', 'Estimated CFO = %f, True CFO = %f.', cfoEst, cfoHz);
                end
            end

            % Write the received resource grid.
            [scs, syms, vals] = find(receivedRG);
            obj.saveDataFile('_test_input_rg', testID, @writeResourceGridEntryFile, ...
                vals, [scs, syms, zeros(length(scs), 1)] - 1);

            % Write the estimated channel.
            [scs, syms, vals] = find(channelEst);
            obj.saveDataFile('_test_output_ch_est', testID, @writeResourceGridEntryFile, ...
                vals, [scs - 1, mod(syms - 1, 14), floor((syms - 1) / 14)]);

            pilots = fullConfig.Pilots;
            % Write the pilots.
            obj.saveDataFile('_test_pilots', testID, @writeComplexFloatFile, pilots(:));

            hop1 = fullConfig.Hop1;
            hop2 = fullConfig.Hop2;
            dmrsPattern = {...
                obj.DMRSsymbols, ...    % symbols
                hop1.maskPRBs,   ...    % rb_mask
                hop2.maskPRBs,   ...    % rb_mask2
                obj.secondHop,   ...    % hopping_symbol_index
                obj.DMRSREmask,  ...    % re_pattern
                };

            if (nLayers >= 2)
                % Layer 1 shares the same resources as layer 0.
                dmrsPattern = {dmrsPattern dmrsPattern};
            end
            if (nLayers >= 3)
                % Layer 2 shares the same time resources as layers 0 and 1,
                % but the RE mask is negated.
                dmrsPattern = [dmrsPattern dmrsPattern(end)];
                dmrsPattern{end}{end} = ~dmrsPattern{end}{end};
            end
            if (nLayers == 4)
                % Layer 3 shares the same resources as layer 2.
                dmrsPattern = [dmrsPattern dmrsPattern(end)];
            end

            startSymbol = Configuration.SymbolAllocation(1);
            nAllocatedSymbols = Configuration.SymbolAllocation(2);
            scsString = sprintf('subcarrier_spacing::kHz%d', SubcarrierSpacing);

            configurationOut = {...
                scsString, ...                   % scs
                'cyclic_prefix::NORMAL', ...     % cp
                startSymbol, ...                 % first_symbol
                nAllocatedSymbols, ...           % nof_symbols
                {dmrsPattern}, ...               % dmrs_patterns
                {0}, ...                         % rx_ports
                betaDMRS, ...                    % betaDMRS
                };

            if isempty(cfoEst)
                cfoEst = {};
            end

            smoothingOut = ['port_channel_estimator_fd_smoothing_strategy::' Configuration.Smoothing];
            context = {...
                configurationOut, ...
                smoothingOut, ...
                Configuration.CFOcompensate, ...
                obj.NSizeGrid, ...
                rsrp, ...
                epre, ...
                SNR, ...
                10 * log10(snrEst), ...
                noiseEst, ...
                timeAlignment * 1e6, ...
                cfo * SubcarrierSpacing * 1000, ...
                cfoEst, ...
                };

            testCaseString = obj.testCaseToString(testID, context, false, ...
                '_test_input_rg', '_test_pilots', '_test_output_ch_est');

            % Add the test to the header file.
            obj.addTestToHeaderFile(obj.headerFileID, testCaseString);

        end % of function testvectorGenerationCases(...)
    end % of methods (Test, TestTags = {'testvector'})

    methods (Test, TestTags = {'testmex'})
        function compareMex(obj, Configuration, SubcarrierSpacing, CarrierOffset)
        %compareMex - Compare mex results with those from the reference estimator for
        %   a given CONFIGURATION, SUBCARRIERSPACING and CARRIEROFFSET.

            import ocuduMEX.phy.ocuduMultiPortChannelEstimator

            [fullConfig, ~, receivedRG, results] = configureAndMatlab(obj, Configuration, SubcarrierSpacing, CarrierOffset);

            hop1 = fullConfig.Hop1;
            hop2 = fullConfig.Hop2;
            pilots = fullConfig.Pilots;
            betaDMRS = fullConfig.BetaDMRS;

            channelEst = results.ChannelEst;
            noiseEst = results.NoiseEst;
            rsrp = results.RSRP;
            epre = results.EPRE;
            timeAlignment = results.TimeAlignment;
            cfoEst = results.CFO;

            % Cast input for the mex estimator.
            pilotRBMask = hop1.maskPRBs * hop1.DMRSsymbols';
            if (~isempty(hop2.maskPRBs) && ~isempty(hop2.DMRSsymbols))
                pilotRBMask = pilotRBMask + hop2.maskPRBs * hop2.DMRSsymbols';
            end
            nPRB = size(hop1.maskPRBs, 1);
            if isfield(Configuration, 'NumLayers')
                nLayers = Configuration.NumLayers;
            else
                nLayers = 1;
            end
            nSymbols = size(hop1.DMRSsymbols, 1);
            [nRE, nCDM] = size(hop1.DMRSREmask);
            pilotMask = nan(nPRB * nRE, nSymbols, nCDM);
            nPilots = sum(pilotRBMask, 'all') * sum(hop1.DMRSREmask(:, 1));
            pilotIndices = nan(nPilots, nLayers);
            for iLayer = 1:2:nLayers
                iCDM = floor(iLayer / 2) + 1;
                pilotMask(:, :, iCDM) = kron(pilotRBMask, hop1.DMRSREmask(:, iCDM));
                pilotIndices(:, iLayer) = find(pilotMask(:, :, iCDM)) + prod(size(receivedRG, [1, 2])) * (iLayer - 1);
                if (iLayer + 1 <= nLayers)
                    pilotIndices(:, iLayer + 1) = pilotIndices(:, iLayer) + prod(size(receivedRG, [1, 2]));
                end
            end

            mexEstimator = ocuduMultiPortChannelEstimator(...
                Smoothing=Configuration.Smoothing, ...
                CompensateCFO=Configuration.CFOcompensate ...
                );
            [channelEstMEX, noiseEstMEX, extra] ...
                = mexEstimator(receivedRG, Configuration.SymbolAllocation, pilotIndices, reshape(pilots, [], nLayers), ...
                    SubcarrierSpacing=SubcarrierSpacing, ...
                    HoppingIndex=hop2.startSymbol, ...
                    BetaScaling=betaDMRS ...
                    );

            % The tolerance for the time alignment is one timing-advance step size
            % (32 samples with a 4096-point DFT).
            toleranceTA = 32000 / (4096 * SubcarrierSpacing);
            chEstIdx = (channelEst ~= 0);
            obj.assertEqual(channelEstMEX(chEstIdx), channelEst(chEstIdx), 'Wrong channel estimates.', AbsTol = 0.008);
            obj.assertEqual(noiseEstMEX, noiseEst, 'Wrong noise variance estimate.', AbsTol = 5e-4);
            obj.assertEqual(extra.RSRP, rsrp, 'Wrong RSRP estimate.', AbsTol = 5e-4);
            obj.assertEqual(extra.EPRE, epre, 'Wrong EPRE estimate.', AbsTol = 5e-4);
            obj.assertEqual(extra.SINR, rsrp * nLayers / betaDMRS^2 / noiseEst, 'Wrong SINR estimate.', RelTol = 0.004);
            obj.assertEqual(extra.TimeAlignment, timeAlignment, 'Wrong time alignment estimate.', AbsTol = toleranceTA);
            obj.assertEqual(extra.CFO, cfoEst, 'Wrong CFO.', RelTol = 0.04);
        end % of function compareMex(...)
    end % of methods (Test, TestTags = {'testmex'})

    methods % public
        function [mse, noiseEst, rsrpEst, epreEst, cfoEst, crlb, nPilots] = characterize(obj, configuration, ...
                scs, channelType, delay, doppler, cfo, snrValues, nRuns, sizeBWP)
        %characterize - Draw the empirical MSE performance curve of the estimator.
        %   MSE = characterize(OBJ, CONFIGURATION, FREQUENCYHOPPING, SCS, NLAYERS, CHANNELTYPE, DELAY, DOPPLER, CFO, SNRVALUES, NRUNS)
        %   returns the empirical mean squared error of the channel estimation after NRUNS simulations
        %   and for all SNRVALUES. CONFIGURATION, FREQUENCYHOPPING, SCS and NLAYERS provide the physical
        %   channel configuration and CHANNELTYPE, DELAY, DOPPLER and CFO specify the simulated channel model.
        %   Note: DELAY is the delay spread for the IEEE channel types, and the Path delay
        %   for the 'pure-delay' channel type.
        %   Note: DOPPLER is the maximum Doppler shift in hertz (effect of scattering), not to
        %   be confused with the CFO.
        %
        %   MSE = characterize(..., BWP) also changes the BWP size (expressed as a number of RBs).
        %   The default BWP size is 51.
        %
        %   [MSE, NOISEEST, RSRPEST, EPREEST, CFOEST, CRLB] = characterize(...) also returns the
        %   estimates of noise variance, RSRP, EPRE and CFO for all runs and all SNR values,
        %   as well as the CRLB for the channel estimation. The CRLB is computed assuming
        %   the entire band is available for estimation, with pilots positioned with
        %   the same pattern as the DM-RS (first column) or with pilots in all REs
        %   (second column).
        %
        %   For CONFIGURATION and FREQUENCYHOPPING, see <a href="matlab:help ocuduChEstimatorUnittest">the main class documentation</a>.
        %   SNRVALUES is an array of SNR values in decibel.
        %   NRUNS is an integer number of simulations.
            arguments
                obj              (1, 1) ocuduChEstimatorUnittest
                configuration    (1, 1) struct {mustBeConfiguration}
                scs              (1, 1) double {mustBeMember(scs, [15, 30])}
                channelType      (1, :) char   {mustBeMember(channelType, {'pure-delay', ...
                    'TDL-A', 'TDL-B', 'TDL-C', 'TDL-D', 'TDL-E', ...
                    'TDLA30', 'TDLB100', 'TDLC300', 'TDLC60'})}
                delay            (1, 1) double {mustBeReal, mustBeNonnegative}
                doppler          (1, 1) double {mustBeReal, mustBeNonnegative}
                cfo              (1, 1) double {mustBeReal}
                snrValues               double {mustBeReal, mustBeVector}
                nRuns            (1, 1) double {mustBeNonnegative, mustBeInteger}
                sizeBWP          (1, 1) double = NaN
            end

            import ocuduLib.phy.upper.signal_processors.ocuduChannelEstimator

            if ~isempty(delay)
                validateattributes(delay, 'double', {'nonnegative'});
            end

            if ~isnan(sizeBWP)
                validateattributes(sizeBWP, 'double', {'positive', 'integer', '<=', 273});
                obj.NSizeBWP = sizeBWP;
                obj.NSizeGrid = obj.NStartBWP + obj.NSizeBWP;
            end

            fullConfig = configureAndMatlab(obj, configuration, scs, []);
            hop1 = fullConfig.Hop1;
            hop2 = fullConfig.Hop2;
            pilots = fullConfig.Pilots;
            betaDMRS = fullConfig.BetaDMRS;
            nPilots = numel(fullConfig.Pilots(:, :, 1));

            % Configure carrier.
            carrier = nrCarrierConfig;
            carrier.CyclicPrefix = 'Normal';
            carrier.SubcarrierSpacing = scs; % kHz
            carrier.NSlot = 0;
            carrier.NSizeGrid = obj.NSizeGrid;

            nLayers = configuration.NumLayers;
            waveformInfo = nrOFDMInfo(carrier);
            channel = configureChannel(channelType, delay, doppler, waveformInfo.SampleRate, ...
                carrier.SubcarrierSpacing, nLayers);

            % Place pilots on the resource grid.
            transmittedRG = obj.transmitPilots(pilots, betaDMRS, hop1, hop2);

            transmittedWF = nrOFDMModulate(carrier, transmittedRG);

            nEstSCS = hop1.nPRBs * obj.NRE;
            if ~isempty(hop2.maskPRBs)
                nEstSCS = nEstSCS * 2;
            end

            mse = zeros(length(snrValues), nEstSCS, nLayers);
            noiseEst = zeros(length(snrValues), nRuns);
            rsrpEst = zeros(length(snrValues), nRuns);
            epreEst = zeros(length(snrValues), nRuns);
            cfoEst = zeros(length(snrValues), nRuns);

            CPDurations = waveformInfo.CyclicPrefixLengths(1:14);
            CPDurations = CPDurations / sum(CPDurations) / scs;

            % Configure estimator.
            EstimatorConfig.nPilotsNoiseAvg = sum(obj.DMRSREmask);
            EstimatorConfig.scs = scs * 1000; % SCS in hertz
            EstimatorConfig.CyclicPrefixDurations = CPDurations;
            EstimatorConfig.Smoothing = configuration.Smoothing;
            EstimatorConfig.CFOCompensate = configuration.CFOcompensate;

            for iRun = 1:nRuns
                reset(channel);
                [receivedWF0, pathGains, sampleTimes] = channel(transmittedWF);

                if cfo ~= 0
                    nSamples = size(receivedWF0, 1);
                    if (~exist('cfoPhase', 'var') || length(cfoPhase) ~= nSamples)
                        timeIx = (0:length(receivedWF0)-1).';
                        cfoPhase = exp(2j * pi * timeIx * cfo / waveformInfo.SampleRate);
                    end
                    receivedWF0 = receivedWF0 .* cfoPhase;
                end

                noise0 = randn(size(receivedWF0)) + 1j * randn(size(receivedWF0));

                iSNR = 0;
                for SNR = snrValues
                    iSNR = iSNR + 1;
                    noiseVar = 10^(-SNR/10) / waveformInfo.Nfft;
                    noise = noise0 * sqrt(noiseVar / 2);

                    receivedWF = receivedWF0 + noise;

                    % Compute received resource grid.
                    receivedRG = nrOFDMDemodulate(carrier, receivedWF);

                    [channelEst, noiseEstL, rsrpEstL, epreEstL, ~, cfoEstL] ...
                        = ocuduChannelEstimator(receivedRG, pilots, betaDMRS, hop1, hop2, EstimatorConfig);
                    noiseEst(iSNR, iRun) = noiseEstL;
                    rsrpEst(iSNR, iRun) = rsrpEstL;
                    epreEst(iSNR, iRun) = epreEstL;
                    cfoEst(iSNR, iRun) = cfoEstL;

                    % Get the true channel, for comparison.
                    pathFilters = channel.getPathFilters();
                    channelTrue = squeeze(nrPerfectChannelEstimate(carrier, pathGains, pathFilters, 0, sampleTimes));

                    if cfo ~= 0
                        cfoNorm = cfo / scs / 1000;
                        cfoFreq = [waveformInfo.CyclicPrefixLengths(1) waveformInfo.CyclicPrefixLengths(2:14) + waveformInfo.Nfft];
                        cfoFreq = cumsum(cfoFreq) * cfoNorm / waveformInfo.Nfft;
                        cfoFreq = exp(2j * pi * cfoFreq);
                        for iLayer = 1:nLayers
                            channelTrue(:, :, iLayer) = channelTrue(:, :, iLayer) * diag(cfoFreq) * exp(1j * pi * ((waveformInfo.Nfft - 1) / waveformInfo.Nfft) * cfoNorm);
                        end
                    end

                    % Just for debugging/analysis purposes: set to true to visualize
                    % the effect of channel and channel estimation on a random QAM
                    % points.
                    if false
                        iLayer = 1; %#ok<UNRCH>
                        whatSymbol = 1+hop1.startSymbol;
                        whatSCS = (channelEst(:, whatSymbol, iLayer) ~= 0);
                        nSCS = sum(whatSCS);
                        % Create some random QAM points.
                        fakeSymbols = ocuduTest.helpers.randmod('QPSK', [nSCS, 50]);

                        % Apply the true channel and ZF-equalize with the estimated channel (SC-wise).
                        rr = diag(channelTrue(whatSCS, whatSymbol, iLayer) ./ channelEst(whatSCS, whatSymbol, iLayer)) * fakeSymbols;

                        if (size(rr, 1) >= 60)
                            % Split edge and middle points, to visualize the difference in
                            % the estimation performance.
                            rrEdge = rr([1:24, end-23:end], :);
                            rrMiddle = rr(25:end-24, :);
                            plot(real(rrEdge(:)), imag(rrEdge(:)), 'rx', real(rrMiddle(:)), imag(rrMiddle(:)), 'bx')
                        else
                            plot(real(rr(:)), imag(rr(:)), 'bx')
                        end
                        pause
                    end

                    scsIdx = obj.NRE * hop1.PRBstart + (1: obj.NRE * hop1.nPRBs);
                    estErrors = channelEst(scsIdx, hop1.CHsymbols, :) - channelTrue(scsIdx, hop1.CHsymbols, :);
                    SQestErrors = squeeze(sum(abs(estErrors).^2, 2));
                    if ~isempty(hop2.maskPRBs)
                        scsIdx = obj.NRE * hop2.PRBstart + (1: obj.NRE * hop2.nPRBs);
                        estErrors2 = channelEst(scsIdx, hop2.CHsymbols, :) - channelTrue(scsIdx, hop2.CHsymbols, :);
                        SQestErrors2 = squeeze(sum(abs(estErrors2).^2, 2));
                    else
                        SQestErrors2 = double.empty(0, nLayers);
                    end

                    for iLayer = 1:nLayers
                        mse(iSNR, :, iLayer) = mse(iSNR, :, iLayer) + [SQestErrors(:, iLayer); SQestErrors2(:, iLayer)]' / nRuns;
                    end
                end
            end

            crlb = repmat(10.^(-snrValues(:)/10), 1, 2) / betaDMRS^2 / sum(hop1.DMRSsymbols);
            crlb = (crlb' .* computeCRLB(hop1.maskPRBs, hop1.DMRSREmask(:, 1)))';
        end % of function characterize(...)
    end % of methods % public

    methods (Access = private)
        function [hop1, hop2] = configureHops(obj, configuration, subcarrierspacing)
        %Creates a description of the resources allocated in each hop.

            startSymbol = configuration.SymbolAllocation(1);
            nAllocatedSymbols = configuration.SymbolAllocation(2);

            % Configure carrier.
            carrier = nrCarrierConfig( ...
                SubcarrierSpacing=subcarrierspacing, ...
                CyclicPrefix='normal', ...
                NSizeGrid=obj.NSizeGrid, ...
                NStartGrid=0);

            nPRBs = configuration.NumPRBs;
            PRBstart = randi([0, obj.NSizeBWP - nPRBs]);
            secondHopStartPRB = randi([0, obj.NSizeBWP - nPRBs]);
            if strcmp(configuration.Channel, 'PUSCH')
                dmrsconfig = nrPUSCHDMRSConfig( ...
                    DMRSConfigurationType=1, ...
                    DMRSTypeAPosition=configuration.DMRSTypeAPosition, ...
                    DMRSAdditionalPosition=configuration.DMRSAdditionalPosition);

                pusch = nrPUSCHConfig( ...
                    NSizeBWP=obj.NSizeBWP, ...
                    NStartBWP=obj.NStartBWP, ...
                    NumLayers=configuration.NumLayers, ...
                    MappingType='A', ...
                    SymbolAllocation=configuration.SymbolAllocation, ...
                    PRBSet=(PRBstart + (0:nPRBs-1)), ...
                    TransformPrecoding=false, ...
                    NumAntennaPorts=configuration.NumLayers, ...
                    FrequencyHopping=configuration.FrequencyHopping, ...
                    SecondHopStartPRB=secondHopStartPRB, ...
                    DMRS=dmrsconfig);

                ind = nrPUSCHDMRSIndices(carrier, pusch, IndexStyle='subscript');

                % Create a DM-RS pattern from the offset and stride.
                obj.DMRSREmask = false(obj.NRE, 1);
                obj.DMRSREmask(ind(1:6, 1) - (PRBstart + 1) * obj.NRE) = true;
            elseif strcmp(configuration.Channel, 'PUCCHF2')
                pucch = nrPUCCH2Config( ...
                    NSizeBWP=obj.NSizeBWP, ...
                    NStartBWP=obj.NStartBWP, ...
                    SymbolAllocation=configuration.SymbolAllocation, ...
                    PRBSet=(PRBstart + (0:nPRBs-1)), ...
                    FrequencyHopping=configuration.FrequencyHopping, ...
                    SecondHopStartPRB=secondHopStartPRB, ...
                    OCCI=randi([0, 3]));

                ind = nrPUCCHDMRSIndices(carrier, pucch, IndexStyle='subscript');

                % Create a DM-RS pattern from the offset and stride.
                obj.DMRSREmask = false(obj.NRE, 1);
                obj.DMRSREmask(ind(1:4, 1) - (PRBstart + 1) * obj.NRE) = true;
            elseif strcmp(configuration.Channel, 'PUCCHF3F4')
                pucch = nrPUCCH3Config( ...
                    NSizeBWP=obj.NSizeBWP, ...
                    NStartBWP=obj.NStartBWP, ...
                    SymbolAllocation=configuration.SymbolAllocation, ...
                    PRBSet=(PRBstart + (0:nPRBs-1)), ...
                    FrequencyHopping=configuration.FrequencyHopping, ...
                    SecondHopStartPRB=secondHopStartPRB, ...
                    AdditionalDMRS=randi([0, 1]), ...
                    OCCI=randi([0, 3]));

                ind = nrPUCCHDMRSIndices(carrier, pucch, IndexStyle='subscript');

                % Create a DM-RS pattern from the offset and stride.
                obj.DMRSREmask = true(obj.NRE, 1);
            else
                error('PHY channel %s not supported.', configuration.Channel);
            end

            % Create a mask of the OFDM symbols carrying DM-RS.
            obj.DMRSsymbols = false(14, 1);
            obj.DMRSsymbols(unique(ind(:, 2))) = true;

            if strcmp(configuration.FrequencyHopping, 'intraSlot')
                obj.secondHop = startSymbol + floor(nAllocatedSymbols / 2);
                hopMask = [true(obj.secondHop, 1); false(obj.nSymbolsSlot - obj.secondHop, 1)];

                hop1.DMRSsymbols = (obj.DMRSsymbols & hopMask);
                if (~isfield(configuration, 'NumLayers') || (configuration.NumLayers <= 2))
                    hop1.DMRSREmask = obj.DMRSREmask;
                else
                    hop1.DMRSREmask = [obj.DMRSREmask ~obj.DMRSREmask];
                end
                hop1.PRBstart = PRBstart;
                hop1.nPRBs = nPRBs;
                hop1.maskPRBs = false(obj.NSizeGrid, 1);
                hop1.maskPRBs(hop1.PRBstart + (1:nPRBs)) = true;
                hop1.startSymbol = startSymbol;
                hop1.nAllocatedSymbols = floor(nAllocatedSymbols / 2);
                hop1.CHsymbols = false(obj.nSymbolsSlot, 1);
                hop1.CHsymbols(hop1.startSymbol + (1:hop1.nAllocatedSymbols)) = true;

                hop2.DMRSsymbols = (obj.DMRSsymbols & (~hopMask));
                hop2.DMRSREmask = hop1.DMRSREmask;
                hop2.PRBstart = secondHopStartPRB;
                hop2.nPRBs = nPRBs;
                hop2.maskPRBs = false(obj.NSizeGrid, 1);
                hop2.maskPRBs(hop2.PRBstart + (1:nPRBs)) = true;
                hop2.startSymbol = obj.secondHop;
                hop2.nAllocatedSymbols = ceil(nAllocatedSymbols / 2);
                hop2.CHsymbols = false(obj.nSymbolsSlot, 1);
                hop2.CHsymbols(hop2.startSymbol + (1:hop2.nAllocatedSymbols)) = true;
            else
                obj.secondHop = 'std::nullopt';

                hop1.DMRSsymbols = obj.DMRSsymbols;
                if (~isfield(configuration, 'NumLayers') || (configuration.NumLayers <= 2))
                    hop1.DMRSREmask = obj.DMRSREmask;
                else
                    hop1.DMRSREmask = [obj.DMRSREmask ~obj.DMRSREmask];
                end
                hop1.PRBstart = PRBstart;
                hop1.nPRBs = nPRBs;
                hop1.maskPRBs = false(obj.NSizeGrid, 1);
                hop1.maskPRBs(hop1.PRBstart + (1:nPRBs)) = true;
                hop1.startSymbol = startSymbol;
                hop1.nAllocatedSymbols = nAllocatedSymbols;
                hop1.CHsymbols = false(obj.nSymbolsSlot, 1);
                hop1.CHsymbols(hop1.startSymbol + (1:hop1.nAllocatedSymbols)) = true;

                hop2.DMRSsymbols = [];
                hop2.maskPRBs = {};
                hop2.startSymbol = [];
            end
        end % of function [hop1 hop2] = configureHops()

        function transmittedRG = transmitPilots(obj, pilots, betaDMRS, hop1, hop2)
        %Places the pilots on the correct REs and with the correct power on the resource grid.
            nLayers = size(pilots, 3);
            transmittedRG = complex(zeros(obj.NSizeGrid * obj.NRE, obj.nSymbolsSlot, nLayers));

            nPilotSymbolsHop1 = sum(hop1.DMRSsymbols);

            processHop(hop1, pilots(:, 1:nPilotSymbolsHop1, :));

            if ~isempty(hop2.DMRSsymbols)
                processHop(hop2, pilots(:, (nPilotSymbolsHop1 + 1):end, :));
            end

            %     Nested functions
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function processHop(hop_, pilots_)
            %Processes the DM-RS corresponding to a single hop.

                % Create a mask for all subcarriers carrying DM-RS.
                maskPRBs_ = hop_.maskPRBs;
                maskREs_ = (kron(maskPRBs_, obj.DMRSREmask) > 0);

                nLayersCDM0_ = min(2, nLayers);
                transmittedRG(maskREs_, hop_.DMRSsymbols, 1:nLayersCDM0_) = betaDMRS * pilots_(:, :, 1:nLayersCDM0_);

                if nLayers > 2
                    % DM-RS for layers 3 and 4 are sent on the complementary set of REs.
                    maskREs_ = (kron(maskPRBs_, ~obj.DMRSREmask) > 0);
                    transmittedRG(maskREs_, hop_.DMRSsymbols, 3:nLayers) = betaDMRS * pilots_(:, :, 3:nLayers);
                end
            end % of function processHop(hop_, pilots_)
        end % of function transmittedRG = transmitPilots(pilots, hop1, hop2)

        function [fullConfig, channel, receivedRG, results] = configureAndMatlab(obj, ...
            Configuration, SubcarrierSpacing, CarrierOffset)
        %Computes secondary configuration parameters and, if the number of output arguments
        %   is larger than one, runs the MATLAB-based channel estimator.

            import ocuduLib.phy.upper.signal_processors.ocuduChannelEstimator
            import ocuduLib.ran.utils.scs2cps
            import ocuduTest.helpers.approxbf16

            obj.assumeFalse(((Configuration.NumPRBs == obj.NSizeBWP) || (Configuration.SymbolAllocation(2) == 1)) ...
                && strcmp(Configuration.FrequencyHopping, 'intraSlot'), ...
                'Cannot do frequency hopping if the entire BWP is allocated or if using a single OFDM symbol.');

            obj.assumeFalse(strcmp(Configuration.Channel, 'PUSCH') && strcmp(Configuration.FrequencyHopping, 'intraSlot') ...
                && (Configuration.DMRSAdditionalPosition > 1), ...
                'When intra-slot frequency hopping is enabled, DMRSAdditionalPosition must be either 0 or 1.');

            assert((sum(Configuration.SymbolAllocation) <= obj.nSymbolsSlot), ...
                'ocudu_matlab:ocuduChEstimatorUnittest', 'Time allocation exceeds slot length.');

            % Configure each hop.
            [hop1, hop2] = obj.configureHops(Configuration, SubcarrierSpacing);

            % Build DM-RS-like pilots.
            nDMRSsymbols = sum(obj.DMRSsymbols);
            if isfield(Configuration, 'NumLayers')
                nLayers = Configuration.NumLayers;
            else
                nLayers = 1;
            end
            nPilots = Configuration.NumPRBs * sum(obj.DMRSREmask) * nDMRSsymbols;
            pilots = complex(nan(nPilots * nLayers, 1), nan(nPilots * nLayers, 1));
            pilots(1:nPilots) = (2 * randi([0 1], nPilots, 2) - 1) * [1; 1j] / sqrt(2);
            pilots = reshape(pilots, [], nDMRSsymbols, nLayers);
            if nLayers >= 2
                % We only simulate the case corresponding to DM-RS configuration type 1.
                % For CDM group 0, i.e. ports {0, 1}, the DM-RS are sent over the same REs
                % and the pilots for port 1 are the same as those of port 0 but for a sign
                % change in every other pilot.
                pilots(:, :, 2) = pilots(:, :, 1);
                pilots(2:2:end, :, 2) = -pilots(2:2:end, :, 2);
            end
            if nLayers >= 3
                % We only simulate the case corresponding to DM-RS configuration type 1.
                % The DM-RS for port 2 are the same as those of port 0, just sent on
                % a disjoint set of REs.
                pilots(:, :, 3) = pilots(:, :, 1);
            end
            if nLayers == 4
                % We only simulate the case corresponding to DM-RS configuration type 1.
                % The DM-RS for port 3 are the same as those of port 1, just sent on
                % a disjoint set of REs.
                pilots(:, :, 4) = pilots(:, :, 2);
            end

            if strcmp(Configuration.Channel, 'PUSCH')
                betaDMRS = sqrt(2);
            else
                betaDMRS = 1;
            end

            fftSize =  obj.NSizeGrid * obj.NRE;

            fullConfig = struct(...
                'Pilots', pilots, ...
                'Hop1', hop1, ...
                'Hop2', hop2, ...
                'BetaDMRS', betaDMRS, ...
                'FFTSize', fftSize ...
                );

            if nargout > 1
                % Place pilots on the resource grid.
                transmittedRG = obj.transmitPilots(pilots, betaDMRS, hop1, hop2);

                cfo = CarrierOffset; % Fraction of the SCS.
                CPDurations = scs2cps(SubcarrierSpacing);

                receivedRG = complex(zeros(fftSize, obj.nSymbolsSlot));
                channelRG = complex(nan(fftSize, obj.nSymbolsSlot, nLayers));

                % For now, consider a single-tap channel (max delay is 1/4 of
                % the cyclic prefix length).
                channelDelay = randi([0, floor(fftSize * 0.07 * 0.25)]);
                for iLayer = 1:nLayers
                    channelCoef = exp(2j * pi * rand) / sqrt(nLayers);
                    channelTF = fft([zeros(channelDelay, 1); channelCoef; zeros(5, 1)], fftSize);
                    channelTF = fftshift(channelTF);
                    % We assume the channel constant over the entire slot...
                    channelRG(:, :, iLayer) = repmat(channelTF, 1, obj.nSymbolsSlot);
                    % ... but for CFO.
                    if cfo ~= 0
                        cfoVal = CPDurations * SubcarrierSpacing;
                        cfoVal(2:end) = cfoVal(2:end) + 1;
                        cfoVal = cumsum(cfoVal) * cfo;
                        cfoVal = exp(2j * pi * cfoVal);
                        channelRG(:, :, iLayer) = (channelRG(:, :, iLayer) .* cfoVal) * exp(1j * pi * ((fftSize - 1) / fftSize) * cfo);
                    end

                    % Compute received resource grid.
                    receivedRG = receivedRG + channelRG(:, :, iLayer) .* transmittedRG(:, :, iLayer);
                end

                SNR = 20; % dB
                noiseVar = 10^(-SNR/10);
                noise = randn(size(receivedRG)) + 1j * randn(size(receivedRG));
                noise(receivedRG == 0) = 0;
                noise = noise * sqrt(noiseVar / 2);
                receivedRG = receivedRG + noise;

                EstimatorConfig.scs = SubcarrierSpacing * 1000;
                EstimatorConfig.CyclicPrefixDurations = CPDurations;
                EstimatorConfig.Smoothing = Configuration.Smoothing;
                EstimatorConfig.CFOCompensate = Configuration.CFOcompensate;
                [channelEst, noiseEst, rsrp, epre, timeAlignment, cfoEst] = ocuduChannelEstimator(approxbf16(receivedRG), ...
                    pilots, betaDMRS, hop1, hop2, EstimatorConfig);

                results = struct(...
                    'ChannelEst', channelEst, ...
                    'NoiseEst', noiseEst, ...
                    'RSRP', rsrp, ...
                    'EPRE', epre, ...
                    'TimeAlignment', timeAlignment, ...
                    'CFO', cfoEst ...
                    );

                channel = struct(...
                    'RG', channelRG, ...
                    'Delay', channelDelay, ...
                    'CFO', cfo, ...
                    'SNR', SNR ...
                    );
            end % of if nargout > 1
        end % of function configureAndMatlab(obj, ...)

    end % of methods (Access = private)
end % of classdef ocuduChEstimatorUnittest

function configuration = generateTestConfig()
% Generates several configurations to test.
    configuration = cell(60, 1);

    PRBvalues = [3, 20, 51];
    nPRBvalues = numel(PRBvalues);

    % Generate 40 PUSCH-like configurations
    for iConf = 1:40
        nSymbols = randi([4, 14]);
        configuration{iConf} = struct( ...
                'Channel', 'PUSCH', ...
                'SymbolAllocation', [0, nSymbols], ...
                'NumPRBs', PRBvalues(randi(nPRBvalues)), ...
                'NumLayers', 2^randi([0, 2]), ...
                'DMRSTypeAPosition', [], ...
                'DMRSAdditionalPosition', [], ...
                'FrequencyHopping', '', ...
                'Smoothing', 'filter', ...
                'CFOcompensate', true ...
            );

        % According to TS38.211 Section 6.4.1.1.3, four allocated symbols require DM-RS position equal to pos2.
        if (nSymbols > 4)
            configuration{iConf}.DMRSTypeAPosition = randi([2, 3]);
        else
            configuration{iConf}.DMRSTypeAPosition = 2;
        end

        % According to TS38.211 Section 6.4.1.1.3, DM-RS additional position pos3 only works with DM-RS position pos2.
        if (configuration{iConf}.DMRSTypeAPosition == 2)
            configuration{iConf}.DMRSAdditionalPosition = randi([0, 3]);
        else
            configuration{iConf}.DMRSAdditionalPosition = randi([0, 2]);
        end

        % Intraslot frequency hopping can be enabled if the number of allocated symbols is at least 8 (4+ symbols
        % per hop), and DM-RS additional position is 0 or 1. If so, enable frequency hopping with 50% probability.
        if ((nSymbols > 8) && (configuration{iConf}.DMRSAdditionalPosition < 2) && (configuration{iConf}.NumPRBs < 51) && (randn < 0))
            configuration{iConf}.FrequencyHopping = 'intraSlot';
        else
            configuration{iConf}.FrequencyHopping = 'neither';
        end
    end

    % Generate 10 PUCCHF2-like configurations.
    for iConf = iConf + (1:10)
        configuration{iConf} = struct( ...
            'Channel', 'PUCCHF2', ...
            'SymbolAllocation', [randi([0, 12]), randi([1, 2])], ...
            'NumPRBs', randi([1, 16]), ...
            'FrequencyHopping', '', ...
            'Smoothing', 'filter', ...
            'CFOcompensate', true ...
        );

        if ((configuration{iConf}.SymbolAllocation(2) == 2) && (randn < 0))
            configuration{iConf}.FrequencyHopping = 'intraSlot';
        else
            configuration{iConf}.FrequencyHopping = 'neither';
        end
    end

    % Generate 10 PUCCHF3F4-like configurations.
    for iConf = iConf + (1:10)
        nSymbols = randi([4, 14]);
        startSymbol = randi([0, 14 - nSymbols]);
        configuration{iConf} = struct( ...
            'Channel', 'PUCCHF3F4', ...
            'SymbolAllocation', [startSymbol, nSymbols], ...
            'NumPRBs', randi([1, 16]), ...
            'FrequencyHopping', '', ...
            'Smoothing', 'filter', ...
            'CFOcompensate', true ...
        );

        if ((configuration{iConf}.SymbolAllocation(2) > 2) && (randn < 0))
            configuration{iConf}.FrequencyHopping = 'intraSlot';
        else
            configuration{iConf}.FrequencyHopping = 'neither';
        end
    end
end % of function generateTestConfig()

function channel = configureChannel(chModel, delay, doppler, SampleRate, SubcarrierSpacing, nLayers)
    channel = nrTDLChannel;
    channel.NumTransmitAntennas = nLayers;
    channel.NumReceiveAntennas = 1;
    channel.MaximumDopplerShift = doppler;
    channel.SampleRate = SampleRate;
    channel.RandomStream = 'Global stream';
    if strcmp(chModel, 'pure-delay')
        channel.DelayProfile = 'Custom';
        if isempty(delay)
            % Random delay, at most one fourth of the cyclic prefix length.
            channel.PathDelays = rand() * 0.018 / SubcarrierSpacing / 1000;
        else
            channel.PathDelays = delay;
        end
        channel.AveragePathGains = 0;
        channel.FadingDistribution = 'Rayleigh';
    elseif ismember(chModel, {'TDL-A', 'TDL-B', 'TDL-C', 'TDL-D', 'TDL-E'})
        channel.DelayProfile = chModel;
        if ~isempty(delay)
            channel.DelaySpread = delay;
        end
    elseif ismember(chModel, {'TDLA30', 'TDLB100', 'TDLC300', 'TDLC60'})
        channel.DelayProfile = chModel;
    else
        error('ocudu_matlab:ocuduChEstimatorUnittest:configureChannel', ...
            'Unknown channel model %s', chModel);
    end
end


function mustBeConfiguration(a)
    if ~isfield(a, 'Channel')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "Channel".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeMember(a.Channel, ["PUSCH", "PUCCHF2", "PUCCHF3F4"]);

    if ~isfield(a, 'NumPRBs')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "NumPRBs".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeScalarOrEmpty(a.NumPRBs);
    mustBeInteger(a.NumPRBs);
    mustBeInRange(a.NumPRBs, 1, 273);

    if ~isfield(a, 'SymbolAllocation')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "SymbolAllocation".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeVector(a.SymbolAllocation)
    if numel(a.SymbolAllocation) ~= 2
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Configuration field "SymbolAllocation" should be an array of two elements.';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeInteger(a.SymbolAllocation);
    mustBeNonnegative(a.SymbolAllocation);
    if (a.SymbolAllocation(1) + a.SymbolAllocation(2) > 14)
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Inconsistent symbol allocation.';
        throwAsCaller(MException(eidType, msgType));
    end

    if strcmp(a.Channel, 'PUSCH')
        if ~isfield(a, 'NumLayers')
            eidType = 'ocuduChEstimatorUnittest:characterize';
            msgType = 'Missing configuration field "NumLayers".';
            throwAsCaller(MException(eidType, msgType));
        end
        mustBeMember(a.NumLayers, [1, 2, 3, 4]);

        if ~isfield(a, 'DMRSTypeAPosition')
            eidType = 'ocuduChEstimatorUnittest:characterize';
            msgType = 'Missing configuration field "DMRSTypeAPosition".';
            throwAsCaller(MException(eidType, msgType));
        end
        mustBeMember(a.DMRSTypeAPosition, [2, 3]);

        if ~isfield(a, 'DMRSAdditionalPosition')
            eidType = 'ocuduChEstimatorUnittest:characterize';
            msgType = 'Missing configuration field "DMRSAdditionalPosition".';
            throwAsCaller(MException(eidType, msgType));
        end
        mustBeMember(a.DMRSAdditionalPosition, [0, 1, 2, 3]);
    end

    if ~isfield(a, 'FrequencyHopping')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "FrequencyHopping".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeMember(a.FrequencyHopping, ["neither", "intraSlot"]);

    if ~isfield(a, 'Smoothing')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "Smoothing".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeMember(a.Smoothing, ["filter", "mean", "none"]);

    if ~isfield(a, 'CFOcompensate')
        eidType = 'ocuduChEstimatorUnittest:characterize';
        msgType = 'Missing configuration field "CFOcompensate".';
        throwAsCaller(MException(eidType, msgType));
    end
    mustBeMember(a.CFOcompensate, [false, true]);
end

function crlb = computeCRLB(prbMask, reMask)
%computeCRLB Cramer-Rao Lower Bound
%   CRLB = computeCRLB(PRBMASK, REMASK) computes the Cramer-Rao Lower Bound (CRLB)
%   for the channel estimation. The CRLB is computed assuming that the entire band
%   can be used for the estimation, with pilots spaced according to REMASK (first
%   entry) or with pilots in all REs (second entry). The assumption is needed to
%   avoid a singular Fisher matrix.

    Nprb = length(prbMask);
    Nre = Nprb * 12; assert(length(reMask) == 12); E = diag(kron(ones(Nprb, 1), reMask)); Jbig = ifft(fft(E, Nre, 2), Nre, 1); cp = floor(Nre / 10); J = Jbig(1:cp, 1:cp);
    s = warning('error', 'MATLAB:nearlySingularMatrix');
    crlb = nan(2, 1);
    chMask = (kron(prbMask, ones(12, 1)) == 1);
    try
        C = inv(J);
        M = fft(ifft(C, Nre, 2), Nre, 1);

        crlb(1) = real(trace(M(chMask, chMask))) / sum(chMask);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix')
            warning('Pattern CRLB can''t be computed.');
        else
            rethrow(ME);
        end
    end

    E = diag(kron(ones(Nprb, 1), ones(12, 1)));
    Jbig = ifft(fft(E, Nre, 2), Nre, 1);
    J = Jbig(1:cp, 1:cp);
    try
        C = inv(J);
        M = fft(ifft(C, Nre, 2), Nre, 1);

        crlb(2) = real(trace(M(chMask, chMask))) / sum(chMask);
    catch ME
        if ~strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix')
            warning('Full CRLB can''t be computed.');
        else
            rethrow(ME);
        end
    end
    warning(s);
end
