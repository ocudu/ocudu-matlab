%pdschDMRSPortTable PDSCH DM-RS antenna port combinations signaled by DCI.
%   PORTTABLE = pdschDMRSPortTable(DMRSTYPE, MAXLENGTH) returns the antenna port
%   combinations of TS38.212 Tables 7.3.1.2.2-1, 7.3.1.2.2-2, 7.3.1.2.2-3 and
%   7.3.1.2.2-4 for the DM-RS configuration type DMRSTYPE (1, 2) and DM-RS maximum
%   length MAXLENGTH (1, 2).
%
%   PORTTABLE is a structure array, with one element per non-reserved table
%   value, containing the following fields:
%
%   Value                   - Value of the DCI antenna ports field. The values
%                             of the one- and two-codeword combinations are
%                             numbered independently, starting at zero.
%   NumCodewords            - Number of enabled codewords (1, 2).
%   NumCDMGroupsWithoutData - Number of DM-RS CDM groups without data.
%   DMRSPorts               - Row vector of zero-based DM-RS ports (i.e., port 0 is
%                             antenna port 1000).
%   NumFrontLoadSymbols     - Number of front-loaded DM-RS symbols.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function portTable = pdschDMRSPortTable(dmrsType, maxLength)

    % Each row contains the number of CDM groups without data, the DM-RS ports and
    % the number of front-load symbols. The row index is the table value.
    if (dmrsType == 1) && (maxLength == 1)
        % TS38.212 Table 7.3.1.2.2-1.
        oneCW = { ...
            1, 0, 1;              ... row 0
            1, 1, 1;              ... row 1
            1, [0, 1], 1;         ... row 2
            2, 0, 1;              ... row 3
            2, 1, 1;              ... row 4
            2, 2, 1;              ... row 5
            2, 3, 1;              ... row 6
            2, [0, 1], 1;         ... row 7
            2, [2, 3], 1;         ... row 8
            2, 0:2, 1;            ... row 9
            2, 0:3, 1;            ... row 10
            2, [0, 2], 1;         ... row 11
            };
        twoCW = cell(0, 3);
    elseif (dmrsType == 1) && (maxLength == 2)
        % TS38.212 Table 7.3.1.2.2-2.
        oneCW = { ...
            1, 0, 1;              ... row 0
            1, 1, 1;              ... row 1
            1, [0, 1], 1;         ... row 2
            2, 0, 1;              ... row 3
            2, 1, 1;              ... row 4
            2, 2, 1;              ... row 5
            2, 3, 1;              ... row 6
            2, [0, 1], 1;         ... row 7
            2, [2, 3], 1;         ... row 8
            2, 0:2, 1;            ... row 9
            2, 0:3, 1;            ... row 10
            2, [0, 2], 1;         ... row 11
            2, 0, 2;              ... row 12
            2, 1, 2;              ... row 13
            2, 2, 2;              ... row 14
            2, 3, 2;              ... row 15
            2, 4, 2;              ... row 16
            2, 5, 2;              ... row 17
            2, 6, 2;              ... row 18
            2, 7, 2;              ... row 19
            2, [0, 1], 2;         ... row 20
            2, [2, 3], 2;         ... row 21
            2, [4, 5], 2;         ... row 22
            2, [6, 7], 2;         ... row 23
            2, [0, 4], 2;         ... row 24
            2, [2, 6], 2;         ... row 25
            2, [0, 1, 4], 2;      ... row 26
            2, [2, 3, 6], 2;      ... row 27
            2, [0, 1, 4, 5], 2;   ... row 28
            2, [2, 3, 6, 7], 2;   ... row 29
            2, [0, 2, 4, 6], 2;   ... row 30
            };
        twoCW = { ...
            2, 0:4, 2;            ... row 0
            2, [0:4, 6], 2;       ... row 1
            2, 0:6, 2;            ... row 2
            2, 0:7, 2;            ... row 3
            };
    elseif (dmrsType == 2) && (maxLength == 1)
        % TS38.212 Table 7.3.1.2.2-3.
        oneCW = { ...
            1, 0, 1;              ... row 0
            1, 1, 1;              ... row 1
            1, [0, 1], 1;         ... row 2
            2, 0, 1;              ... row 3
            2, 1, 1;              ... row 4
            2, 2, 1;              ... row 5
            2, 3, 1;              ... row 6
            2, [0, 1], 1;         ... row 7
            2, [2, 3], 1;         ... row 8
            2, 0:2, 1;            ... row 9
            2, 0:3, 1;            ... row 10
            3, 0, 1;              ... row 11
            3, 1, 1;              ... row 12
            3, 2, 1;              ... row 13
            3, 3, 1;              ... row 14
            3, 4, 1;              ... row 15
            3, 5, 1;              ... row 16
            3, [0, 1], 1;         ... row 17
            3, [2, 3], 1;         ... row 18
            3, [4, 5], 1;         ... row 19
            3, 0:2, 1;            ... row 20
            3, 3:5, 1;            ... row 21
            3, 0:3, 1;            ... row 22
            2, [0, 2], 1;         ... row 23
            };
        twoCW = { ...
            3, 0:4, 1;            ... row 0
            3, 0:5, 1;            ... row 1
            };
    elseif (dmrsType == 2) && (maxLength == 2)
        % TS38.212 Table 7.3.1.2.2-4.
        oneCW = { ...
            1, 0, 1;              ... row 0
            1, 1, 1;              ... row 1
            1, [0, 1], 1;         ... row 2
            2, 0, 1;              ... row 3
            2, 1, 1;              ... row 4
            2, 2, 1;              ... row 5
            2, 3, 1;              ... row 6
            2, [0, 1], 1;         ... row 7
            2, [2, 3], 1;         ... row 8
            2, 0:2, 1;            ... row 9
            2, 0:3, 1;            ... row 10
            3, 0, 1;              ... row 11
            3, 1, 1;              ... row 12
            3, 2, 1;              ... row 13
            3, 3, 1;              ... row 14
            3, 4, 1;              ... row 15
            3, 5, 1;              ... row 16
            3, [0, 1], 1;         ... row 17
            3, [2, 3], 1;         ... row 18
            3, [4, 5], 1;         ... row 19
            3, 0:2, 1;            ... row 20
            3, 3:5, 1;            ... row 21
            3, 0:3, 1;            ... row 22
            2, [0, 2], 1;         ... row 23
            3, 0, 2;              ... row 24
            3, 1, 2;              ... row 25
            3, 2, 2;              ... row 26
            3, 3, 2;              ... row 27
            3, 4, 2;              ... row 28
            3, 5, 2;              ... row 29
            3, 6, 2;              ... row 30
            3, 7, 2;              ... row 31
            3, 8, 2;              ... row 32
            3, 9, 2;              ... row 33
            3, 10, 2;             ... row 34
            3, 11, 2;             ... row 35
            3, [0, 1], 2;         ... row 36
            3, [2, 3], 2;         ... row 37
            3, [4, 5], 2;         ... row 38
            3, [6, 7], 2;         ... row 39
            3, [8, 9], 2;         ... row 40
            3, [10, 11], 2;       ... row 41
            3, [0, 1, 6], 2;      ... row 42
            3, [2, 3, 8], 2;      ... row 43
            3, [4, 5, 10], 2;     ... row 44
            3, [0, 1, 6, 7], 2;   ... row 45
            3, [2, 3, 8, 9], 2;   ... row 46
            3, [4, 5, 10, 11], 2; ... row 47
            1, 0, 2;              ... row 48
            1, 1, 2;              ... row 49
            1, 6, 2;              ... row 50
            1, 7, 2;              ... row 51
            1, [0, 1], 2;         ... row 52
            1, [6, 7], 2;         ... row 53
            2, [0, 1], 2;         ... row 54
            2, [2, 3], 2;         ... row 55
            2, [6, 7], 2;         ... row 56
            2, [8, 9], 2;         ... row 57
            };
        twoCW = { ...
            3, 0:4, 1;            ... row 0
            3, 0:5, 1;            ... row 1
            2, [0:3, 6], 2;       ... row 2
            2, [0:3, 6, 8], 2;    ... row 3
            2, [0:3, 6:8], 2;     ... row 4
            2, [0:3, 6:9], 2;     ... row 5
            };
    else
        error('Invalid DM-RS type %d and maximum length %d.', dmrsType, maxLength);
    end

    portTable = [toStruct(oneCW, 1); toStruct(twoCW, 2)];
end

function entries = toStruct(rows, numCodewords)
    numRows = size(rows, 1);
    entries = struct('Value', num2cell((0:numRows - 1).'), ...
        'NumCodewords', numCodewords, ...
        'NumCDMGroupsWithoutData', rows(:, 1), ...
        'DMRSPorts', rows(:, 2), ...
        'NumFrontLoadSymbols', rows(:, 3));
end
