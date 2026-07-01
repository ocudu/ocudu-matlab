% ocuduUCIEncode Encode uplink control information (UCI).
%   Encodes UCI payload bits into a codeword by partitioning it into Part 1 and
%   Part 2 according to code rate and length constraints. It then encodes each payload
%   part individually using nrUCIEncode and concatenates them to form the final codeword.
%
%   Syntax
%     [codeword] = ocuduUCIEncode(payloadPart1, payloadPart2, totalCodeWordLength, ...
%                                 modulationOrder, maxCodeRate)
%
%   Input arguments
%     payloadPart1        - UCI bits for Part 1.
%     payloadPart2        - UCI bits for Part 2.
%     totalCodeWordLength - Total number of coded bits/symbols.
%     modulationOrder     - Modulation order (e.g., 2 for BPSK, 4 for QPSK).
%     maxCodeRate         - Maximum allowable code rate [0, 1].
%
%   Output arguments
%     codeword            - Concatenated encoded bits for Part 1 and Part 2.
%
%   Notes
%     - The function relies on ocuduUCICodeWordLengths to determine partition sizes.
%     - CRC attachment, if required by the PUCCH format, must be performed prior to encoding.
%     - This function handles codeword construction but does not perform modulation mapping
%       or PUCCH resource allocation.
%     - Group hopping and advanced rate matching are not handled within this function.
%
%   See also nrUCIEncode, ocuduUCICodeWordLengths

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [codeword] = ocuduUCIEncode(payloadPart1, payloadPart2, totalCodeWordLength, modulationOrder, maxCodeRate)
    import ocuduLib.phy.upper.channel_processors.pucch.ocuduUCICodeWordLengths

    % Calculate codeword lengths.
    [part1CodeWordLength, part2CodeWordLength] = ocuduUCICodeWordLengths(length(payloadPart1), ...
        length(payloadPart2), totalCodeWordLength, modulationOrder, maxCodeRate);

    % Encode part 1 payload.
    cwPart1 = nrUCIEncode(payloadPart1, part1CodeWordLength);

    % Encode part 2 payload.
    cwPart2 = nrUCIEncode(payloadPart2, part2CodeWordLength);

    % Concatenate both codewords.
    codeword = [cwPart1; cwPart2];
end
