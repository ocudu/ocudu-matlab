%matlab2ocuduCyclicPrefix Generates a Cyclic Prefix string.
%   CYCLICPREFIXSTR = matlab2ocuduCyclicPrefix(CYCLICPREFIX) returns a
%   CYCLICPREFIXSTR string that can be used to specify the Cyclic Prefix in
%   the test header files. CYCLICPREFIX must be in the format specified by
%   nrCarrierConfig.
%
%   See also nrCarrierConfig.CyclicPrefix.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function CyclicPrefixStr = matlab2ocuduCyclicPrefix(CyclicPrefix)
    CyclicPrefixStr = 'cyclic_prefix::';
    if (strcmp(CyclicPrefix, 'normal'))
        CyclicPrefixStr = [CyclicPrefixStr  'NORMAL'];
    elseif (strcmp(CyclicPrefix, 'extended'))
        CyclicPrefixStr = [CyclicPrefixStr  'EXTENDED'];
    else
        error('matlab2ocuduCP:InvalidCP', 'Invalid CP type.');
    end
