%ocuduPUCCH4Demodulator PUCCH Format 4 demodulation.
%   softBits = ocuduPUCCH4Demodulator(CARRIER, PUCCH, RXSYMBOLS, DATACHESTS, NOISEVAR)
%   demodulates the received symbols RXSYMBOLS for the given CARRIER and PUCCH
%   configurations and returns the resulting SOFTBITS.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.
function softBits = ocuduPUCCH4Demodulator(carrier, pucch, rxSymbols,dataChEsts, noiseVar)
    import ocuduLib.phy.upper.channel_modulation.ocuduDemodulator
    import ocuduLib.phy.upper.equalization.ocuduChannelEqualizer
    import ocuduLib.phy.generic_functions.transform_precoding.ocuduTransformDeprecode
    import ocuduLib.phy.upper.channel_processors.pucch.ocuduPUCCH4InverseBlockwiseSpreading

    % PUCCH Format 4 uses a single PRB.
    numPRB = 1;

    % PUCCH uses a single layer.
    numLayers = 1;

    % Equalize channel symbols.
    [eqSymbols, eqNoiseVars] = ocuduChannelEqualizer(rxSymbols, dataChEsts, 'ZF', noiseVar, 1);

    % Inverse transform precoding.
    [spreadSymbols, spreadNoiseVars] = ocuduTransformDeprecode(eqSymbols, eqNoiseVars, numPRB, numLayers);

    % Inverse block-wise spreading.
    [~, info] = nrPUCCHIndices(carrier, pucch);
    [modSymbols, noiseVars] = ocuduPUCCH4InverseBlockwiseSpreading(...
        spreadSymbols, spreadNoiseVars, pucch.SpreadingFactor, info.Gd, pucch.OCCI);

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
