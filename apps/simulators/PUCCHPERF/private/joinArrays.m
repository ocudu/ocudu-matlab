%joinArrays Join counter arrays for PUCCHPERF.
%   Removes from arrayA the elements indexed by removeFromA, concatenates the
%   contents of arrayB and then reorders the obtained array according to the
%   indices in outputOrder.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function mixedArray = joinArrays(arrayA, arrayB, removeFromA, outputOrder)
    arrayA(removeFromA) = [];
    mixedArray = [arrayA; arrayB];
    mixedArray = mixedArray(outputOrder);
end
