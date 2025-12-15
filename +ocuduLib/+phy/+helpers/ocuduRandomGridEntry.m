%ocuduRandomGridEntry Generates a random set of resource grid symbols and indices.
%   [SYMBOLS, INDICES] = ocuduRandomGridEntry(CARRIER, PORTIDX) generates a set of
%   complex symbols SYMBOLS and its related indices INDICES, emulating a fully
%   allocated resource grid for a given carrier CARRIER and a given port PORTIDX.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [symbols, indices] = ocuduRandomGridEntry(carrier, portIdx)

    nofSymbols = carrier.SymbolsPerSlot;
    nofSubcarriers = carrier.NSizeGrid * 12;
    symbols = [1 1j] * (2 * rand(2, nofSymbols * nofSubcarriers) - 1);
    indices = nan(nofSymbols * nofSubcarriers, 3);
    symbolOffset = 0;
    for symbolIdx = 0:nofSymbols-1
        indices(symbolOffset + (1:nofSubcarriers), 1) = 0:nofSubcarriers-1;
        indices(symbolOffset + (1:nofSubcarriers), 2) = ones(1, nofSubcarriers) * symbolIdx;
        indices(symbolOffset + (1:nofSubcarriers), 3) = ones(1, nofSubcarriers) * portIdx;
        symbolOffset = symbolOffset + nofSubcarriers;
    end

end
