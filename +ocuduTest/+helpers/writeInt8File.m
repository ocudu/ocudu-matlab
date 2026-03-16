%writeInt8File Generates a new binary file with 'int8_t' entries.
%   writeInt8File(FILENAME, DATA) writes the numeric array DATA to the binary
%   file FILENAME (pathname). The format matches the 'file_vector<int8_t>' object
%   used by OCUDU.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function writeInt8File(filename, data)
    fileID = fopen(filename, 'w');
    fwrite(fileID, data, 'int8');
    fclose(fileID);
end
