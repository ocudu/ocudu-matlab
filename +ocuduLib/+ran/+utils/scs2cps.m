%scs2cps Returns the duration (in ms) of the CPs for one slot depending on the SCS.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function cpDurations = scs2cps(scs)
    if (scs == 15)
        cpDurations = [160 144 144 144 144 144 144 160 144 144 144 144 144 144];
    elseif (scs == 30)
        cpDurations = [160 144 144 144 144 144 144 144 144 144 144 144 144 144];
    end
    cpDurations = cpDurations / sum(cpDurations) / scs;
end
