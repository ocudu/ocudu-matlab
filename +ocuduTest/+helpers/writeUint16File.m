%writeUint16File Generates a new binary file with 'uint16_t' entries.
%   writeUint16File(FILENAME, DATA) writes the numeric array DATA to the binary
%   file FILENAME (pathname).

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function writeUint16File(filename, data)
    fileID = fopen(filename, 'w');
    dataLength = length(data);
    for idx = 1:dataLength
        fwrite(fileID, data(idx), 'uint16');
    end
    fclose(fileID);
end
