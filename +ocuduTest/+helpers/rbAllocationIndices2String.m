%rbAllocationIndices2String Generates an RB allocation string object compatible with ocudu.
%   OUTPUTSTRING = rbAllocationIndices2String(VRBINDICES)
%   generates an RB allocation string OUTPUTSTRING from a vector of VRB
%   indices VRBINDICES.
%
%   In order to save space, the function detects if the allocation is
%   contiguous for a number of VRB. In that case, it constructs a type1
%   allocation with a start and an end VRB index.
%
%   If the allocation is not contiguous, it constructs a custom allocation.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function [output] = rbAllocationIndices2String(vrbIndices)

    firstRB = vrbIndices(1);
    lastRB = vrbIndices(end);
    countRB = lastRB - firstRB + 1;
    if length(vrbIndices) == countRB
        output = sprintf('rb_allocation::make_type1(%d, %d)', firstRB, ...
        countRB);
    else
        output = ['rb_allocation::make_custom({', ...
        ocuduTest.helpers.array2str(vrbIndices), '})'];
    end
end
