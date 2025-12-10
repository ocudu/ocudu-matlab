%ocuduPUCCH3Demodulator PUCCH Format 3 demodulation.
%   softBits = ocuduPUCCH3Demodulator(PUCCH, RXSYMBOLS, DATACHESTS, NOISEVAR)
%   demodulates the received symbols RXSYMBOLS for the given PUCCH Format 3
%   configuration and returns the resulting SOFTBITS.

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.
function softBits = ocuduPUCCH3Demodulator(pucch, rxSymbols,dataChEsts, noiseVar)
    import ocuduLib.phy.upper.channel_modulation.ocuduDemodulator
    import ocuduLib.phy.upper.equalization.ocuduChannelEqualizer
    import ocuduLib.phy.generic_functions.transform_precoding.ocuduTransformDeprecode
    import ocuduLib.phy.upper.channel_processors.pucch.ocuduPUCCH4InverseBlockwiseSpreading

    % PUCCH uses a single layer.
    numLayers = 1;

    % Equalize channel symbols.
    [eqSymbols, eqNoiseVars] = ocuduChannelEqualizer(rxSymbols, dataChEsts, 'ZF', noiseVar, 1);

    % Inverse transform precoding.
    [modSymbols, noiseVars] = ocuduTransformDeprecode(eqSymbols, eqNoiseVars, length(pucch.PRBSet), numLayers);

    % Convert equalized symbols into softbits.
    softBits = ocuduDemodulator(modSymbols(:), pucch.Modulation, noiseVars(:));

    % Scrambling sequence for PUCCH.
    scSequence = nrPUCCHPRBS(pucch.NID, pucch.RNTI, length(softBits));

    % Encode the scrambling sequence into the sign, so it can be
    % used with soft bits.
    scSequence = -(scSequence * 2) + 1;

    % Apply descrambling.
    softBits = softBits .* scSequence;
end
