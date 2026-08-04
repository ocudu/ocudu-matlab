%% SRS-based Direction of Arrival
% This script summarizes the main concepts behind SRS-based Direction of Arrival
% (DoA) estimation (also, Angle of Arrival, AoA).

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

%%
% We start by configuring carrier and SRS transmission.

% For the sake of a concrete example, let us configure the carrier with a 50-MHz
% bandwidth and 30-kHz subcarrier spacing.
carrier = nrCarrierConfig;
carrier.SubcarrierSpacing = 30;
carrier.NSizeGrid = 133;

% Next, we need to configure the SRS transmission, according to TS38.211 Section
% 6.4.1.4. As far as DoA is concerned, most of the parameters are not important
% and we can keep the default values. For instance, at least for now, we don't
% consider frequency hopping or partial frequency sounding (and frequency scaling).
%
% However, there are some parameters that are important either because they limit
% the scope of this initial study, or because they are essential to guarantee
% acceptable performances of the DoA algorithm. For instance, to better estimate
% the covariance matrix of the received signal across the antennas, it is
% fundamental to collect as many samples as possible: since the number of OFDM
% symbols carrying SRS is limited to fourteen, we compensate by configuring a
% large-bandwidth SRS by setting CSRS = 33 and BSRS = 0 (see TS38.211 Table 6.4.1.4.3-1).
srs = nrSRSConfig;
srs.CSRS = 33;
srs.BSRS = 0;

% With a large-bandwidth SRS, we can limit the number of OFDM symbols.
srs.NumSRSSymbols = 4;
srs.SymbolStart = 9;

% Set the number of antenna ports to one: recall that DoA is based on the
% assumption that the antenna array at the Rx side is exposed to a plane wave
% from a transmitter that can be considered in the far field.
srs.NumSRSPorts = 1;

% We set the flag SRSPositioning, which corresponds to the higher-layer parameter
% *SRS-PosResource.* Even if the name suggests it is related to positioning
% applications of SRS, it does not seem to have major effects on the SRS transmission
% other than constraining the number of SRS symbols and the transmission comb number.
srs.SRSPositioning = true;

%%
% Having configured the SRS transmission, let us generate the signal.

% Generate the SRS signal and use it to fill the resource grid.
srsSymbols = nrSRS(carrier, srs);
srsIndices = nrSRSIndices(carrier, srs);
gridTx = nrResourceGrid(carrier);
gridTx(srsIndices) = srsSymbols;

% Render the transmitted grid.
renderResourceGrid(gridTx);

%%
% Let us now focus on the receive side. For the time being, we limit our analysis
% to Uniform Linear Arrays (ULAs). The geometry of the array plays a fundamental
% role in the DoA estimation algorithm and is strictly related to the signal
% bandwidth. Indeed, we need to ensure that the signals sensed at the array
% elements differ only by a phase term because of the delay, while the "data"
% signal must be common across the entire array. For this reason, it is often said
% that the transmitted signal should be narrowband, meaning that the inverse of
% the bandwidth should be significantly larger than the maximum delay between
% elements.

% Fix the number of receive antennas.
numRxAntennas = 8;

% Fix the carrier frequency: 3489.42 MHz is a reasonable value and corresponds
% to ARFCN 632628 (band n78).
carrierFrequency = 3.48942e9; % hertz

% Compute the wavelength in meters.
lightSpeed = physconst("LightSpeed"); % meters per second
wavelength = lightSpeed / carrierFrequency; % meters

% Maximum delay, assuming antennas are half-wavelength far apart.
elementDistance = wavelength / 2; % meters
maxDelay = numRxAntennas * elementDistance / lightSpeed; % seconds

% Compare with the inverse of the signal bandwidth, to check the narrowband
% assumption.
subcarriersRB = 12;
signalBW = carrier.NSizeGrid * subcarriersRB * carrier.SubcarrierSpacing * 1000; % hertz
assert(maxDelay < 1 / (10 * signalBW), ...
    "Carrier frequency, signal bandwidth and antenna geometry do not satisfy the narrowband assumption.");

%%
% Next, we create a random channel frequency response for the SRS signal. This
% step may seem to clash with the DoA assumption that the receiver
% sees a plane wave from a source in the far field, as well as with the
% narrowband assumption discussed above. However, we include a static (no doppler
% shift), low-selective frequency response as an easy way to model any
% imperfection in the measurements. One can also think of the frequency selectivity
% as the result of scatterers close to the transmitter (in the far-field on the
% antenna array). Moreover, a more rigorous analysis of the signal model (in
% preparation) suggests that adding frequency selectivity doesn't limit the
% applicability of DoA algorithms under consideration.

% Create a channel frequency response and apply it to the signal, together with
% the delay due to the array geometry. Also, add some noise.
channelFR = generatechannel(carrier);
snrdB = 10;
noiseVar = 10^(-snrdB / 10);

gridSize = size(gridTx);
gridRx = complex(nan([gridSize numRxAntennas]));
gridRx(:, :, 1) = channelFR .* gridTx;

% Set the broadside angle of arrival.
broadsideAngle = -27; % degrees, between -90 and 90.
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
    gridRx(:, :, iAntenna) = phaseShift .* gridRx(:, :, 1);

    noiseMatrix = (randn(gridSize) + 1j * randn(gridSize)) * sqrt(noiseVar / 2);
    gridRx(:, :, iAntenna) = gridRx(:, :, iAntenna) + noiseMatrix;
end
% Add noise to the first antenna, which was left "clean" to simplify
% calculations.
noiseMatrix = (randn(gridSize) + 1j * randn(gridSize)) * sqrt(noiseVar / 2);
gridRx(:, :, 1) = gridRx(:, :, 1) + noiseMatrix;

%%
% For a more interesting example, we can add a second source. The signal is
% generated as before (except that no extra noise is added).

addSecondSource = true;
if addSecondSource
    % Set to true if the second source is simply a reflection of the first one
    % (same SRS, but different channel). If false, the SRS generator will be
    % initialized with a different cyclic shift, while maintaining all other parameters.
    isReflection = true;
    broadsideAngle2 = -20;

    arrayGeometry.NumRxAntennas = numRxAntennas;
    arrayGeometry.ElementDistance = elementDistance;

    % The generation of the second source follows the same steps as before (no
    % extra noise is added).
    gridRx = gridRx + secondSource(srs, isReflection, arrayGeometry, carrier, carrierFrequency, broadsideAngle2);

    nSources = 2;
else
    nSources = 1; %#ok<UNRCH>
end

%%
% Finally, the estimation algorithm is applied to the received signal.

% First, compute the "sample covariance matrix."
allSamples = complex(nan(numRxAntennas, size(srsIndices, 1)));
for iAntenna = 1:numRxAntennas
    allSamples(iAntenna, :) = gridRx(srsIndices + (iAntenna - 1) * prod(gridSize));
end
sampleCovMatrix = allSamples * allSamples';

[doa, spectrum] = musicDoA(sampleCovMatrix, nSources);
figure
plot(-90:90, spectrum);
xlabel('Broadside angle [degrees]')
ylabel('MUSIC spectrum')
hold on;
plot(broadsideAngle * [1, 1], [0, max(spectrum)], ':k')
labels(1:nSources+1) = "";
labels(1) = "MUSIC";
labels(2) = "true DoA source 1";

if addSecondSource
    plot(broadsideAngle2 * [1, 1], [0, max(spectrum)], '-.k')
    labels(3) = "true DoA source 2";
end
legend(labels)

%% Helper functions

function renderResourceGrid(resGrid)
    % Render resource grid, simply showing where the signal is transmitted.
    clf;
    nREs = size(resGrid, 1);
    imagesc([0.5, 13.5], [0.5, nREs-0.5], abs(resGrid).^2);
    set(gca, 'YDir','normal');
    axis([0 14 0 nREs-1]);
    xticks(0:2:14);
    title('Full-Band SRS');
    xlabel('OFDM symbol index');
    ylabel('Resource element');
    grid on;
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

function [doas, spectrum] = musicDoA(sampleCovMatrix, nSignals)
    % MUSIC DoA estimation. This version of the algorithm is very basic, for instance
    % it assumes that the number of sources is known and it does a grid search
    % in the entire range of broadside angles.
    [vectors, ~] = eig(sampleCovMatrix);
    nAntennas = size(sampleCovMatrix, 1);
    noiseSize = nAntennas - nSignals;
    noiseProj = vectors(:, 1:noiseSize) * vectors(:, 1:noiseSize)';

    sweepPoints = (-90:90)';
    nPoints = numel(sweepPoints);
    spectrum = nan(nPoints, 1);
    for iPoint = 1:nPoints
        q = sweepPoints(iPoint);
        % The signature depends on the ratio between the distance between consecutive
        % antennas and the wavelength. In this simplified implementation, we only
        % consider the ratio to be 0.5.
        distanceOverLambda = 0.5;
        signature = exp(-2j * pi * (0:nAntennas-1)' * distanceOverLambda * sin(pi * q / 180));
        spectrum(iPoint) = 1 / real(signature' * noiseProj * signature);
    end
    [~, ix] = sort(spectrum, "descend");
    doas = sweepPoints(ix(1: nSignals));
end

function gridRx = secondSource(srs, isReflection, arrayGeometry, carrier, carrierFrequency, broadsideAngle)
    % Generate a second source. The process is the same as the one explained in
    % the main body of the tutorial and, hence, is not fully commented.

    if ~isReflection
        % If the second source is not a reflection of the first one, pick a different
        % cyclic shift to obtain an SRS that is orthogonal to the first one.
        srs.CyclicShift = 4;
    end
    srsSymbols = nrSRS(carrier, srs);
    srsIndices = nrSRSIndices(carrier, srs);
    gridTx = nrResourceGrid(carrier);
    gridTx(srsIndices) = srsSymbols;

    % Compute the wavelength in meters.
    lightSpeed = physconst("LightSpeed"); % meters per second
    wavelength = lightSpeed / carrierFrequency; % meters

    % Maximum delay, assuming antennas are half-wavelength far apart.
    elementDistance = arrayGeometry.ElementDistance;
    numRxAntennas = arrayGeometry.NumRxAntennas;

    % Create a channel frequency response and apply it to the signal, together with
    % the delay due to the array geometry. Also, add some noise.
    channelFR = generatechannel(carrier);

    gridSize = size(gridTx);
    gridRx = complex(nan([gridSize numRxAntennas]));
    gridRx(:, :, 1) = channelFR .* gridTx;

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
        gridRx(:, :, iAntenna) = phaseShift .* gridRx(:, :, 1);
    end
end
