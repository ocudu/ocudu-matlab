%writeInt16File Generates a new binary file with 'int16_t' entries.
%   writeInt16File(FILENAME, DATA) writes the numeric array DATA to the binary
%   file FILENAME (pathname). The format matches the 'file_vector<int16_t>'
%   object used by OCUDU.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function writeInt16File(filename, data)
    fileID = fopen(filename, 'w');
    dataLength = length(data);
    for idx = 1:dataLength
        fwrite(fileID, data(idx), 'int16');
    end
    fclose(fileID);
end
