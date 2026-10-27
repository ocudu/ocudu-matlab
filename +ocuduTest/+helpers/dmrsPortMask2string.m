%dmrsPortMask2string Generates a DM-RS port bitmask string.
%   OUTPUTSTRING = dmrsPortMask2string(PORTSET)
%   generates a DM-RS port bitmask string OUTPUTSTRING from a vector of
%   zero-based DM-RS ports PORTSET (i.e., port 0 is antenna port 1000). The
%   bitmask always has 12 entries, the maximum number of DM-RS ports.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function outputString = dmrsPortMask2string(portSet)
    import ocuduTest.helpers.cellarray2str
    portMask = zeros(12, 1); % maximum possible number of DM-RS ports
    portMask(portSet + 1) = 1;
    outputString = cellarray2str({portMask}, false);
end
