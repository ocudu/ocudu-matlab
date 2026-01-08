%joinArrays Join counter arrays for PUCCHPERF.
%   Removes from arrayA the elements indexed by removeFromA, concatenates the
%   contents of arrayB and then reorders the obtained array according to the
%   indices in outputOrder.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function mixedArray = joinArrays(arrayA, arrayB, removeFromA, outputOrder)
    arrayA(removeFromA) = [];
    mixedArray = [arrayA; arrayB];
    mixedArray = mixedArray(outputOrder);
end
