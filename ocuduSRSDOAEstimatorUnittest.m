%ocuduSRSDOAEstimatorUnittest Unit tests for SRS DOA estimator functions.
%   This class implements unit tests for the DOA estimator functionality using the
%   matlab.unittest framework. The simplest use consists in creating an object with
%      testCase = ocuduSRSDOAEstimatorUnittest
%   and then running the tests with
%      testResults = testCase.run
%
%   ocuduSRSDOAEstimatorUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'doa_estimator').
%   ocuduBlockType  - The type of the tested block, including layer
%                        (i.e., 'phy/upper/signal_processors/srs').
%
%   ocuduSRSDOAEstimatorUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduSRSDOAEstimatorUnittest Properties (TestParameter):
%
%   NumRxAntennas   - Number of receive antenna ports (2, 4, 8).
%   CrossPolarized  - Cross-polarization flag.
%
%   ocuduSRSDOAEstimatorUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduSRSDOAEstimatorUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduSRSDOAEstimatorUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'doa_estimator'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/signal_processors/srs'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'srs_estimator' tests will be erased).
        outputPath = {['testSRSDOA', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Number of receive antenna ports.
        NumRxAntennas = {4, 8, 16}

        %Cross-polarization flag.
        %   When set to true, each pair of consecutive antenna ports is assumed to consists
        %   of two collocated antenna elements with opposite polarizations.
        CrossPolarized = {false, true}
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)

            fprintf(fileID, '#include "ocudu/adt/complex.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/signal_processors/srs/doa_estimator_configuration.h"\n');
            fprintf(fileID, '#include "ocudu/support/file_tensor.h"\n');

        end

        function addTestDefinitionToHeaderFile(~, fileID)

            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, '  doa_estimator_configuration doa_config;\n');
            fprintf(fileID, '  std::vector<float>          expected_angles;\n');
            fprintf(fileID, '  std::vector<float>          expected_spectrum;\n');
            fprintf(fileID, '  file_tensor<2, cf_t>        data;\n');
            fprintf(fileID, '  file_tensor<2, cf_t>        srs_sequences;\n');
            fprintf(fileID, '};\n');

        end

    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})
        function testvectorGenerationCases(testCase, NumRxAntennas, CrossPolarized)
        %testvectorGenerationCases Generates a test vector for the given number of antennas
        %   and CrossPolarized flag. The remaining parameters are set randomly.

            import ocuduTest.helpers.writeComplexFloatFile

            % Generate a unique test ID.
            testID = testCase.generateTestID;

            % Carrier configuration.
            carrier = nrCarrierConfig;
            carrier.SubcarrierSpacing = 30; % kHz
            carrier.NSizeGrid = 133;
            carrierFrequency = 3.48942e9; % hertz

            % SRS configuration: pick CSRS and BSRS for a large bandwidth, and
            % one Tx port. The remaining parameters are not critical and we pick
            % sensible values.
            srs = nrSRSConfig;
            srs.CSRS = 33;
            srs.BSRS = 0;
            srs.NumSRSPorts = 1;
            srs.NumSRSSymbols = 4;
            srs.SymbolStart = 10;
            srs.SRSPositioning = true;

            % Antenna geometry: for now, we only consider Uniform Linear Arrays
            % (ULAs), and the geometry is defined by the number of antennas and
            % the distance between any two consecutive elements.
            % If the flag CrossPolarized is set, each pair of consecutive antenna
            % ports is assumed to consist of two collocated elements with orthogonal
            % polarizations.
            arrayGeometry.NumRxAntennas = NumRxAntennas;
            arrayGeometry.ElementDistance = 0.043; % meters
            arrayGeometry.CrossPolarized = CrossPolarized;

            % List of cyclic shifts: repeated shifts are interpreted as a UE
            % that is received through multiple reflections.
            % NOTE: We are using transmission comb number KTC = 2, so the cyclic shift
            % can take values between 0 and 7.
            % NOTE: Currently, the OCUDU SRS estimator (and, thus, the DOA estimator)
            % only supports one UE per occasion. For this reason, we only pick one
            % cyclic shift.
            cyclicShifts = repmat(randi([0, 7]), randi(floor(NumRxAntennas / 2)), 1);
            numSources = numel(cyclicShifts);

            % Angles of arrivals in degrees (between -90 and 90): the order matches that of the cyclic shifts.
            angleOptions = (-90:5:90)';
            anglesArrival = angleOptions(randperm(numel(angleOptions), numSources));
            assert(numel(anglesArrival) == numSources, "The number of cyclic shifts and of angles of arrival do not match.");

            % Generate the signal as seen from the receive antennas.
            symbolsCell = cell(numSources, 1);
            srs.CyclicShift = cyclicShifts(1);
            [gridRx, symbolsCell{1}, srsIndices] = generateRxSRS(carrier, carrierFrequency, srs, arrayGeometry, anglesArrival(1));

            % If we have multiple sources then generate more signals keep all parameters
            % the same except the cyclic shift and the angle of arrival.
            for iSource = 2:numSources
                srs.CyclicShift = cyclicShifts(iSource);
                [tmp, symbolsCell{iSource}, ~] = generateRxSRS(carrier, carrierFrequency, srs, arrayGeometry, anglesArrival(iSource));
                % Scaling factor to mimic different Rx powers.
                sf = 0.5 + 0.5 * rand;
                gridRx = gridRx + sf * tmp;
            end

            % Keep only unique symbols.
            [~, ixShifts, ~] = unique(cyclicShifts);
            symbols = [symbolsCell{ixShifts}];

            % Add some noise.
            snrdB = 10;
            noiseVar = 10^(-snrdB / 10);
            gridSize = size(gridRx);
            noiseMatrix = (randn(gridSize) + 1j * randn(gridSize)) * sqrt(noiseVar / 2);
            gridRx = gridRx + noiseMatrix;

            %
            % Rx Side.
            %

            % Extract SRS symbols.
            allSamples = complex(nan(size(srsIndices, 1), NumRxAntennas));
            for iAntenna = 1:NumRxAntennas
                allSamples(:, iAntenna) = gridRx(srsIndices + (iAntenna - 1) * prod(gridSize(1:2)));
            end

            [angles, ~, spectrum] = ocuduLib.phy.upper.signal_processors.ocuduDOAEstimator(allSamples, symbols, ...
                arrayGeometry, carrierFrequency);

            testCase.saveDataFile('_test_input_data', testID, @writeComplexFloatFile, allSamples(:));
            testCase.saveDataFile('_test_srs', testID, @writeComplexFloatFile, symbols(:));

            distanceOverWavelength = arrayGeometry.ElementDistance * carrierFrequency / physconst("LightSpeed");

            doaConfig = {...
                NumRxAntennas, ...                     % nof_antennas
                distanceOverWavelength, ...            % antenna_distance_over_wavelength
                CrossPolarized, ...                    % cross_polarized
                };

            testContext = { ...
                doaConfig, ...                         % doa_config
                num2cell(angles, 1), ...               % expected_angles
                num2cell(spectrum(angles+91), 1) ...   % expected_spectrum
                };

            testCaseString = testCase.testCaseToString(testID, ...
                testContext, false, {'_test_input_data', num2cell(size(allSamples))}, {'_test_srs', num2cell(size(symbols))});

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);

        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduSRSUnittest

function [gridRx, srsSymbols, srsIndices] = generateRxSRS(carrier, carrierFrequency, srs, arrayGeometry, broadsideAngle)
%generateRxSRS generates the SRS signal as seen by the Rx antenna array.
%   carrier           - Carrier configuration.
%   carrierFrequency  - Carrier frequency.
%   srs               - SRS configuration.
%   arrayGeometry     - Struct describing the antenna array geometry
%                       (for now, only ULAs are supported and the geometry is
%                       described by the number of antennas and the distance
%                       between consecutive elements).
%   broadsideAngle    - Broadside angle of arrival in degrees.

    srsSymbols = nrSRS(carrier, srs);
    srsIndices = nrSRSIndices(carrier, srs);
    gridTx = nrResourceGrid(carrier);
    gridTx(srsIndices) = srsSymbols;

    % Compute the wavelength in meters.
    lightSpeed = physconst("LightSpeed"); % meters per second
    wavelength = lightSpeed / carrierFrequency; % meters

    elementDistance = arrayGeometry.ElementDistance;
    numRxAntennas = arrayGeometry.NumRxAntennas;

    if arrayGeometry.CrossPolarized
        numRxAntennasTotal = 2 * numRxAntennas;

        % Collocated antennas with orthogonal polarizations receive the same signal
        % except for a gain and a 90-degree rotation.
        polarizationGain = (0.5 + rand) * 1j;
    else
        numRxAntennasTotal = numRxAntennas;
    end

    % Create a channel frequency response and apply it to the signal, together with
    % the delay due to the array geometry. Also, add some noise.
    channelFR = generatechannel(carrier);

    gridSize = size(gridTx);
    gridRx = complex(nan([gridSize numRxAntennasTotal]));
    gridRx(:, :, 1) = channelFR .* gridTx;

    if arrayGeometry.CrossPolarized
        gridRx(:, :, 2) = polarizationGain * gridRx(:, :, 1);

        stepAntenna = 2;
    else
        stepAntenna = 1;
    end

    % Set the broadside angle of arrival.
    broadsideAngleSin = sin(broadsideAngle * pi / 180);

    % At this point, we consider each subcarrier as a different plane wave. Therefore,
    % at each antenna element, the phase shift depends on the "radio frequency" of
    % each subcarrier, that is, for subcarrier n,
    %   carrierFrequency + n * subcarrierSpacing.
    n = (0:(gridSize(1)-1))';
    carrierCorrection = 1 + n * carrier.SubcarrierSpacing * 1000 / carrierFrequency;
    for iAntenna = 2:numRxAntennas
        delayNormalized = broadsideAngleSin * (iAntenna - 1) * elementDistance / wavelength;
        phaseShift = exp(-2j * pi * delayNormalized * carrierCorrection);
        iAntennaTotal = (iAntenna - 1) * stepAntenna + 1;
        gridRx(:, :, iAntennaTotal) = phaseShift .* gridRx(:, :, 1);

        if arrayGeometry.CrossPolarized
            gridRx(:, :, iAntennaTotal + 1) = polarizationGain * gridRx(:, :, iAntennaTotal);
        end
    end
end

function h = generatechannel(carrier)
    % Generate a low-frequency selective channel response to model measurement
    % impairments.
    info = nrOFDMInfo(carrier);
    channel = nrTDLChannel;
    % Use the global random stream to have different realizations at each call.
    channel.RandomStream = "Global stream";
    channel.NumTransmitAntennas = 1;
    channel.NumReceiveAntennas = 1;
    channel.MaximumDopplerShift = 0;
    channel.DelayProfile = "TDLA10";
    channel.ChannelFiltering = false;
    channel.ChannelResponseOutput = "ofdm-response";
    channel.SampleRate = info.SampleRate;

    hfull = channel(carrier);
    h = hfull(:, 1);
    h = h * sqrt(size(h, 1)) / norm(h);
end
