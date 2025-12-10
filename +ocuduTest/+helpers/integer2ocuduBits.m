%integer2ocuduBits Convert a nonnegative integer to an OCUDU amount of bits.
%   B = integer2ocuduBits(I) converts the nonnegative integer I to an initialization
%   string of a "ocudu::units::bits" variable containing I bits.

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

function bitString = integer2ocuduBits(int)
    arguments
        int (1, 1) double {mustBeInteger, mustBeNonnegative}
    end

    bitString = sprintf('units::bits(%d)', int);
end
