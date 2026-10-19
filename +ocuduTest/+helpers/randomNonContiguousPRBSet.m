%randomNonContiguousPRBSet Generates a random non-contiguous PRB allocation.
%   PRBSET = randomNonContiguousPRBSet(NSIZEBWP) returns a row vector PRBSET of
%   zero-based PRB indices within a BWP of NSIZEBWP PRBs. The allocation consists
%   of periodic blocks of PRBs with random block size, gap, offset and span,
%   e.g. [2:4, 9:11, 16:18]. It always includes at least one PRB of the second
%   block, so it is never contiguous. NSIZEBWP must be at least 17.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function PRBSet = randomNonContiguousPRBSet(nSizeBWP)

    assert(nSizeBWP >= 17, 'The BWP must have at least 17 PRBs.');

    blockSize = randi([1, 8]);
    gapSize = randi([1, 8]);
    period = blockSize + gapSize;

    % Limit the offset so that the second block starts within the BWP.
    offset = randi([0, min(period - 1, nSizeBWP - period - 1)]);

    % Include at least one PRB of the second block, so the allocation is not contiguous.
    spanEnd = randi([offset + period + 1, nSizeBWP]);
    prbIndices = offset:(spanEnd - 1);
    PRBSet = prbIndices(mod(prbIndices - offset, period) < blockSize);
end
