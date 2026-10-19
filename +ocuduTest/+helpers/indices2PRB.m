%indices2PRB Generates the list of PRBs occupied by a set of resource elements.
%   PRBINDICES = indices2PRB(INDICES) returns the sorted, zero-based indices
%   PRBINDICES of the PRBs containing at least one of the Resource Element (RE)
%   indices INDICES.
%
%   INDICES is a two-dimensional array comprising a list of zero-based
%   Resource Element (RE) locations, where the first column is the subcarrier
%   index, the second column is the OFDM symbol index, and the third one is
%   the antenna port index.
%
%   See also indices2SymbolMask.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function prbIndices = indices2PRB(indices)

    nSubcarriersPerRB = 12;
    prbIndices = unique(floor(double(indices(:, 1)) / nSubcarriersPerRB));

end
