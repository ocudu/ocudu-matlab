%writeComplexFloatFile Writes complex symbols to a binary file.
%   writeComplexFloatFile(FILENAME, DATA) generates a new binary file FILENAME
%    containing a set of complex symbols, formatted to match the 'file_vector<cf_t>'
%    object used by the OCUDU gNB.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function writeComplexFloatFile(filename, data)
    % Flatten data.
    data = data(:);

    % Convert data to single precission floating point with interleaved
    % real and imaginary parts.
    singleRealData = nan(1, 2 * numel(data), 'single');
    singleRealData(1:2:end) = real(data);
    singleRealData(2:2:end) = imag(data);

    % Open file, write data and close file.
    fileID = fopen(filename, 'w');
    fwrite(fileID, singleRealData, 'float32');
    fclose(fileID);
end
