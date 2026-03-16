%writeUint8File Generates a new binary file with 'uint8_t' entries.
%   writeUint8File(FILENAME, DATA) writes the numeric array DATA to the binary
%   file FILENAME (pathname).

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function writeUint8File(filename, data)
    fileID = fopen(filename, 'w');
    dataLength = length(data);
    for idx = 1:dataLength
        fwrite(fileID, data(idx), 'uint8');
    end
    fclose(fileID);
end
