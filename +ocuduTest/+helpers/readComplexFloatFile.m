%readComplexFloatFile Reads complex symbols from a binary file.
%   DATA = readComplexFloatFile(FILENAME) opens and reads an existent
%   binary file FILENAME containing a set of complex symbols, formatted to
%   match the 'file_vector<cf_t>' object used by the OCUDU gNB.
%
%   DATA = readComplexFloatFile(FILENAME, OFFSET, SIZE), similarly to the
%   previous call, but the first sample offset and number of samples is
%   specified through arguments.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function data = readComplexFloatFile(filename, varargin)
% Open the file.
fileID = fopen(filename, 'r');

% If there is two additional argument, take it as the offset from the
% beginning of the file (BOF).
if length(varargin) == 2
    % Calculate offset in bytes assuming each sample consists of eight
    % bytes.
    offsetBytes = 8 * varargin{1};
    fseek(fileID, offsetBytes, 'bof');

    % Calculate the number of samples assuming each sample consists of
    % two single precision values.
    nofSingleDataReal = 2 * varargin{2};

    % Read all the samples.
    singleRealData = fread(fileID, nofSingleDataReal, 'float32');
elseif isempty(varargin)
    % Read all the samples.
    singleRealData = fread(fileID, 'float32');
else
    error('Invalid number of inputs.');
end

% Close the file.
fclose(fileID);

% Convert real data to complex.
data = singleRealData(1:2:end) + 1i * singleRealData(2:2:end);
end
