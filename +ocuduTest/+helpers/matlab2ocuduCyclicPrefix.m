%matlab2ocuduCyclicPrefix Generates a Cyclic Prefix string.
%   CYCLICPREFIXSTR = matlab2ocuduCyclicPrefix(CYCLICPREFIX) returns a
%   CYCLICPREFIXSTR string that can be used to specify the Cyclic Prefix in
%   the test header files. CYCLICPREFIX must be in the format specified by 
%   nrCarrierConfig.
%
%   See also nrCarrierConfig.CyclicPrefix.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function CyclicPrefixStr = matlab2ocuduCyclicPrefix(CyclicPrefix)
    CyclicPrefixStr = 'cyclic_prefix::';
    if (strcmp(CyclicPrefix, 'normal'))
        CyclicPrefixStr = [CyclicPrefixStr  'NORMAL'];
    elseif (strcmp(CyclicPrefix, 'extended'))
        CyclicPrefixStr = [CyclicPrefixStr  'EXTENDED'];
    else
        error('matlab2ocuduCP:InvalidCP', 'Invalid CP type.');
    end
