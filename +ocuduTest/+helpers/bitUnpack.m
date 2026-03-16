%bitUnpack Simple data-unpacking function.
%   UNPACKEDDATA = bitUnpack(DATA) converts a set of packed uint8 input values
%   (i.e., all 8 bits carry useful data) DATA into a set of unpacked double binary
%   values PACKEDDATA.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function unpackedData = bitUnpack(data)
    unpackedData = int2bit(data, 8);
end
