%symbolAllocationMask2string Generates a new OFDM symbol allocation bitmask string.
%   OUTPUTSTRING = symbolAllocationMask2string(SYMBOLINDICESVECTOR)
%   generates a symbol bitmask allocation string OUTPUTSTRING from a vector of indices
%   SYMBOLINDICESVECTOR.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function outputString = symbolAllocationMask2string(symbolIndicesVector)
    import ocuduTest.helpers.cellarray2str
    symbolAllocation = zeros(14, 1); % maximum possible number of symbols
    for symbolIndex = symbolIndicesVector(:, 2)
      symbolAllocation(symbolIndex + 1) = 1;
    end
    outputString = cellarray2str({symbolAllocation}, false);

end
