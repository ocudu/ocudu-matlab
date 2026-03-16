%writeFloatFile Writes real-valued float symbols to a binary file.
%   writeFloatFile(FILENAME, DATA) generates a new binary file FILENAME
%   containing a set of real-valued symbols, formatted to match the 'file_vector<float>'
%   object used by the OCUDU gNB.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function writeFloatFile(filename, data)
    fileID = fopen(filename, 'w');
    fwrite(fileID, data, 'float32');
    fclose(fileID);
end
