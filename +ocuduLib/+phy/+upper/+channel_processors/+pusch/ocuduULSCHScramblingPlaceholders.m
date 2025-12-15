%ocuduULSCHScramblingPlaceholders Generate UL-SCH Scrambling placeholders
%position.
%   [xInd, yInd] = ocuduULSCHScramblingPlaceholders(PUSCH, TCR, TBS, OACK, OCSI1, OCSI2)
%   generates a list of UL-SCH scrambling repetition placeholders x and a list of placeholders y.
%
%   See also nrULSCHInfo, nrULSCHDemultiplex, nrPUSCHDecode

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [xInd, yInd] = ocuduULSCHScramblingPlaceholders(pusch, tcr, tbs, ...
                OAck, OCsi1, OCsi2)

    % Get UL-SCH information.
    info = nrULSCHInfo(pusch, tcr, tbs, OAck, OCsi1, OCsi2);

    % Create SCH codeword with all zeros.
    schBits = zeros(info.GULSCH, 1);

    % Create HARQ-ACK bits to zero, encode and rate match.
    ackBits = zeros(OAck, 1);
    ackEncBits = nrUCIEncode(ackBits, info.GACK, pusch.Modulation);

    % Create CSI-Part1 bits to zero, encode and rate match.
    csi1Bits = zeros(OCsi1, 1);
    csi1EncBits = nrUCIEncode(csi1Bits, info.GCSI1, pusch.Modulation);
    
    % Create CSI-Part2 bits to zero, encode and rate match.
    csi2Bits = zeros(OCsi2, 1);
    csi2EncBits = nrUCIEncode(csi2Bits, info.GCSI2, pusch.Modulation);
    
    % Multiplex message, placeholders are marked as -2.
    encBits = nrULSCHMultiplex(pusch, tcr, tbs, schBits, ackEncBits, csi1EncBits, csi2EncBits);

    % Create bit indices list.
    indexes = transpose(0:length(encBits) - 1);

    % Select the bit indices that are x placeholders.
    xInd = indexes(encBits == -1);

    % Select the bit indices that are y placeholders.
    yInd = indexes(encBits == -2);
end
