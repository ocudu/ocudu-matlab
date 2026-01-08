%bitUnpack Simple data-unpacking function.
%   UNPACKEDDATA = bitUnpack(DATA) converts a set of packed uint8 input values
%   (i.e., all 8 bits carry useful data) DATA into a set of unpacked double binary
%   values PACKEDDATA.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function unpackedData = bitUnpack(data)
    unpackedData = int2bit(data, 8);
end
