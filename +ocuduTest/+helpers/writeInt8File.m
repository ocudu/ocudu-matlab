%writeInt8File Generates a new binary file with 'int8_t' entries.
%   writeInt8File(FILENAME, DATA) writes the numeric array DATA to the binary
%   file FILENAME (pathname). The format matches the 'file_vector<int8_t>' object
%   used by OCUDU.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function writeInt8File(filename, data)
    fileID = fopen(filename, 'w');
    fwrite(fileID, data, 'int8');
    fclose(fileID);
end
