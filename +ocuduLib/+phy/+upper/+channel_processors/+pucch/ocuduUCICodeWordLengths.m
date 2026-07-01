% ocuduUCICodeWordLengths Calculate codeword lengths for UCI Part 1 and Part 2.
%   Computes the codeword lengths for UCI Part 1 and Part 2 from the total
%   number of rate-matched bits. The formulas are given in TS38.212
%   Table 6.3.1.4.1-1.
%
%   Syntax
%     [part1CodeWordLength, part2CodeWordLength] = ocuduUCICodeWordLengths(part1PayloadLength, ...
%         part2PayloadLength, totalCodewordLength, modulationOrder, maxCodeRate)
%
%   Input arguments
%     part1PayloadLength    - Number of payload bits in Part 1.
%     part2PayloadLength    - Number of payload bits in Part 2.
%     totalCodewordLength   - Total number of encoded bits/symbols.
%     modulationOrder       - Modulation order (e.g., 2 for BPSK, 4 for QPSK).
%     maxCodeRate           - Maximum allowable code rate [0, 1].
%
%   Output arguments
%     part1CodeWordLength   - Codeword length for Part 1.
%     part2CodeWordLength   - Codeword length for Part 2.
%
%   Notes
%     - CRC length for Part 1 is computed internally based on the payload size.
%     - Part 2 codeword length is derived as total minus Part 1 length.
%
%   See also ocuduUCIEncode, nrUCIEncode

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [part1CodeWordLength, part2CodeWordLength] = ocuduUCICodeWordLengths(part1PayloadLength, ...
        part2PayloadLength, totalCodewordLength, modulationOrder, maxCodeRate)
    % No part 2.
    if (part2PayloadLength == 0)
        part1CodeWordLength = totalCodewordLength;
        part2CodeWordLength = 0;
        return;
    end

    % Calculate payload Part 1 CRC length.
    if (part1PayloadLength < 12)
        L = 0;
    elseif (part1PayloadLength < 20)
        L = 6;
    else
        L = 11;
    end

    if ((part1PayloadLength > 1013) || ((part1PayloadLength > 360) && (totalCodewordLength > 1088)))
      L = 2 * L;
    end

    % Calculate Part 1 codeword length.
    num = 100 * (part1PayloadLength + L);
    den = round(100 * maxCodeRate * modulationOrder);
    numSymbols = ceil(num / den);
    part1CodeWordLength = numSymbols * modulationOrder;

    % Calculate Part 2 codeword length.
    part2CodeWordLength = totalCodewordLength - part1CodeWordLength;
end

