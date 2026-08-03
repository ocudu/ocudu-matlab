%ocuduDOAEstimator SRS-based Direction of Arrival estimator.
%   [ANGLES, UES, SPECTRUM] = ocuduDOAEstimator(SAMPLES, SRS, GEOMETRY, CARRIERFREQUENCY)
%   decomposes the signal in SAMPLES into a number of plane waves and, for each
%   plane wave, estimates the angle of arrival. For each antenna in the array, the
%   corresponding column of matrix SAMPLES contains the frequency-time samples of
%   the received signal, which is assumed to be the result of transmitting the
%   sounding reference signals in matrix SRS through a number of possibly
%   frequency selective channels. Matrix SRS has as many rows as the rows of
%   SAMPLES and as many columns as the number of UEs transmitting SRS on the
%   sensed resources. The antenna array is assumed to be a Uniform Linear Array
%   (ULA), with the number of elements (NumRxAntennas) and the distance between
%   consecutive elements (ElementDistance, in meters) specified by structure
%   GEOMETRY. The extra field CrossPolarized is a boolean flag that, if set to
%   true, indicates that each pair of consecutive antenna ports consists of two
%   collocated, cross-polarized elements. In this case, the signals from the two
%   polarizations alternate in the rows of SAMPLES (i.e., rows n and n+1 contain
%   the samples from two collocated elements). CARRIERFREQUENCY is the carrier
%   frequency expressed in hertz.
%
%   The function returns, in array ANGLES, the estimated angles of arrival.
%   Array UES contains, for each angle of arrival, the index of the SRS column
%   that is estimated to generate the detected plane wave. The estimation is based
%   on the MUSIC algorithm, whose spectrum is returned in SPECTRUM.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [angles, ues, spectrum] = ocuduDOAEstimator(samples, srs, arrayGeometry, carrierFrequency)
    arguments
        samples           (:, :) double {mustBeNumeric}
        srs               (:, :) double {mustBeNumeric}
        arrayGeometry     (1, 1) struct
        carrierFrequency  (1, 1) double {mustBePositive}
    end

    % Validate inputs.
    [numSamples, numRxAntennas] = size(samples);
    assert(size(srs, 1) == numSamples, "The number of samples per antenna is not equal to the number of SRS symbols.");
    numSourcesNoReflect = size(srs, 2);

    assert(arrayGeometry.NumRxAntennas == numRxAntennas, ...
        "The number antenna ports inferred from the data is not equal to the configured one.");
    crossPolarized = arrayGeometry.CrossPolarized;
    assert(~crossPolarized || (mod(numRxAntennas, 2) == 0), ...
           "For cross-polarized antenna arrays, the number of antenna ports must be even.");

    % Diagonalize sample covariance matrix and separate signal and noise
    % eigenvalues.
    sampleCovMatrix = conj(samples' * samples) / numSamples;

    [eigvectors, eigvaluesMatrix] = eig(sampleCovMatrix);
    eigvalues = diag(eigvaluesMatrix);

    noiseEigvalues = findnoiseeig(eigvalues, numSourcesNoReflect);
    numNoiseEigvalues = numel(noiseEigvalues);
    noiseEigvectors = eigvectors(:, 1:numNoiseEigvalues);
    noiseProj = noiseEigvectors * noiseEigvectors';

    elementDistance = arrayGeometry.ElementDistance;
    lightSpeed = physconst("LightSpeed"); % meters per second
    wavelength = lightSpeed / carrierFrequency; % meters
    distanceOverLambda = elementDistance / wavelength;

    % Brute force search of impinging plane waves.
    sweepPoints = (-90:90)';
    nPoints = numel(sweepPoints);
    spectrum = nan(nPoints, 1);
    signatureAll = complex(nan(numRxAntennas, nPoints));
    for iPoint = 1:nPoints
        q = sweepPoints(iPoint);
        if crossPolarized
            [signatureAll(:, iPoint), spectrum(iPoint)] = computeSpectrumCrossPolarized(noiseEigvectors, q, numRxAntennas, distanceOverLambda);
        else
            signatureAll(:, iPoint) = exp(-2j * pi * (0:numRxAntennas-1)' * distanceOverLambda * sin(pi * q / 180));
            spectrum(iPoint) = 1 / real(signatureAll(:, iPoint)' * noiseProj * signatureAll(:, iPoint));
        end
    end
    [~, ix] = findpeaks(spectrum, SortStr="descend");
    numSignals = min(numRxAntennas - numNoiseEigvalues, numel(ix));
    ixSignal = ix(1:numSignals);
    angles = sweepPoints(ixSignal);
    signatures = signatureAll(:, ixSignal);

    % Assign each detected wave to the SRS signal with the highest scalar
    % product.
    signals = samples / signatures.';
    lses = abs(signals' * srs);
    ues = ones(numSignals, 1);
    for iUE = 2:numSourcesNoReflect
        ues(lses(:, iUE) > max(lses, 2)) = iUE;
    end
end % of function ocuduDOAEstimator(samples, srs, arrayGeometry)

function noiseEigvalues = findnoiseeig(eigvalues, numSourcesNoReflect)
% Estimates which eigenvalues belong to the noise-only space: "eigenvalues" is
% an ascending sorted array of eigenvalues of the sample covariance matrix. The
% smallest eigenvalue always belongs to the noise space. The remaining
% eigenvalues, considered in increasing order, are assigned to the noise space
% if their value doesn't exceed the average of the current noise eigenvalues by
% more than 50%.
    numValues = numel(eigvalues);

    runningavg = cumsum(eigvalues) ./ (1:numValues)';
    mask = true(numValues, 1);
    for i = 2:numValues
        mask(i) = (eigvalues(i) < 1.5 * runningavg(i-1));
    end

    % The number of signal eigenvalues is bounded below by numSourcesNoReflect.
    mask((end - numSourcesNoReflect + 1):end) = false;

    noiseEigvalues = eigvalues(mask);
end

function [signature, spectrum] = computeSpectrumCrossPolarized(noiseEigvectors, bsangle, numRxAntennas, distanceOverLambda)
% Solves the MUSIC problem when the antenna array consists of pairs of
% cross-polarized elements.
%
% Assuming numRxAntennas/2 cross-polarized elements (i.e., two collocated ports
% with different polarizations) with normalized inter-element distance
% distanceOverLambda, the function generates the array signature corresponding
% to broadside angle bsangle and computes the MUSIC spectrum from the noise eigenvectors.

    signatureTmp = exp(-2j * pi * (0:numRxAntennas/2-1)' * distanceOverLambda * sin(pi * bsangle / 180));

    % The same signature can be applied to the subarrays corresponding to the
    % two orthogonal polarizations.
    componentH = noiseEigvectors(1:2:end, :)' * signatureTmp;
    componentV = noiseEigvectors(2:2:end, :)' * signatureTmp;

    componentHNorm2 = componentH' * componentH;
    componentVNorm2 = componentV' * componentV;
    componentCross = componentH' * componentV;

    % Compute the minimum eigenvalue of the matrix
    %   [componentHNorm2        componentCross
    %    componentCross*        componentVNorm2].
    lambdaMin = componentHNorm2 + componentVNorm2;
    lambdaMin = lambdaMin - sqrt((componentHNorm2 - componentVNorm2)^2 + 4 * abs(componentCross)^2);
    lambdaMin = lambdaMin / 2;

    spectrum = 1 / lambdaMin;

    signature = complex(zeros(numRxAntennas, 1));
    if (lambdaMin == componentHNorm2)
        signature(1:2:end) = signatureTmp;
    else
        % Eigenvector corresponding to the minimum eigenvalue.
        v = [componentCross / (componentHNorm2 - lambdaMin); -1];
        v = v / norm(v);
        signature(1:2:end) = v(1) * signatureTmp;
        signature(2:2:end) = v(2) * signatureTmp;
    end
end
