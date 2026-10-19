%RBallocationMask2string Generates an RB allocation bitmask string.
%   OUTPUTSTRING = RBallocationMask2string(PRBINDICES)
%   generates an RB bitmask allocation string OUTPUTSTRING from a vector of
%   zero-based PRB indices PRBINDICES.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function outputString = RBallocationMask2string(prbIndices)

    rbAllocation = zeros(max(prbIndices) + 1, 1);
    rbAllocation(prbIndices + 1) = 1;

    import ocuduTest.helpers.cellarray2str
    outputString = cellarray2str({rbAllocation}, false);

end
