%integer2ocuduBits Convert a nonnegative integer to an OCUDU amount of bits.
%   B = integer2ocuduBits(I) converts the nonnegative integer I to an initialization
%   string of a "ocudu::units::bits" variable containing I bits.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function bitString = integer2ocuduBits(int)
    arguments
        int (1, 1) double {mustBeInteger, mustBeNonnegative}
    end

    bitString = sprintf('units::bits(%d)', int);
end
