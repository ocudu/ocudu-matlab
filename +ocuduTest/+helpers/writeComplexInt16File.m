%writeComplexInt16File Writes complex 16-bit integer samples to a binary file.
%   writeComplexInt16File(FILENAME, DATA) generates a new binary file FILENAME
%   containing a set of complex 16-bit integer samples, formatted to match the
%   'file_vector<ci16_t>' object used by the OCUDU gNB. DATA must be of class int16.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function writeComplexInt16File(filename, data)
    arguments
        filename (1, :) char
        data int16
    end

    % Flatten data.
    data = data(:);

    % Interleave real and imaginary parts.
    int16RealData = zeros(1, 2 * numel(data), 'int16');
    int16RealData(1:2:end) = real(data);
    int16RealData(2:2:end) = imag(data);

    % Open file, write data and close file.
    fileID = fopen(filename, 'w');
    fwrite(fileID, int16RealData, 'int16');
    fclose(fileID);
end
