%writeFloatFile Writes real-valued float symbols to a binary file.
%   writeFloatFile(FILENAME, DATA) generates a new binary file FILENAME
%   containing a set of real-valued symbols, formatted to match the 'file_vector<float>'
%   object used by the OCUDU gNB.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function writeFloatFile(filename, data)
    fileID = fopen(filename, 'w');
    fwrite(fileID, data, 'float32');
    fclose(fileID);
end
