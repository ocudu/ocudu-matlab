%ocuduPUCCH3Demodulator PUCCH Format 3 demodulation.
%   softBits = ocuduPUCCH3Demodulator(PUCCH, RXSYMBOLS, DATACHESTS, NOISEVAR)
%   demodulates the received symbols RXSYMBOLS for the given PUCCH Format 3
%   configuration and returns the resulting SOFTBITS.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%
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
