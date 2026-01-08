%ocuduTransformDeprecode Reverts transform precoding.
%   [data, noise] = ocuduTransformDeprecode(eqDataSymb, eqNoiseVar, numPRB, numLayers)
%   reverts the transform precoding operation and estimates the equivalent
%   noise variant.
%
%   See also nrTransformDeprecode.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [dataSymb, noiseVar] = ocuduTransformDeprecode(eqDataSymb, eqNoiseVar, numPRB, numLayers)
    % Deduce the number of subcarriers and OFDM symbols.
    numSubC = 12 * numPRB;
    numSymbols = length(eqNoiseVar) / numSubC;

    % Revert transform precoding.
    dataSymb = nrTransformDeprecode(eqDataSymb, numPRB);

    % Process noise variance.
    % Reorganize noise variance in OFDM symbols.
    noiseVar = reshape(eqNoiseVar, numSubC, numLayers * numSymbols);
    % Average across OFDM symbols.
    noiseVar = ones(size(noiseVar)) .* mean(noiseVar, 1);
    % Reorganize to match the original shape.
    noiseVar = reshape(noiseVar, numSubC * numSymbols, numLayers);
end

