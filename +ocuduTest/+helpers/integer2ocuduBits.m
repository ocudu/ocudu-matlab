%integer2ocuduBits Convert a nonnegative integer to an OCUDU amount of bits.
%   B = integer2ocuduBits(I) converts the nonnegative integer I to an initialization
%   string of a "ocudu::units::bits" variable containing I bits.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function bitString = integer2ocuduBits(int)
    arguments
        int (1, 1) double {mustBeInteger, mustBeNonnegative}
    end

    bitString = sprintf('units::bits(%d)', int);
end
