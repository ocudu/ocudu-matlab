%scs2cps Returns the duration (in ms) of the CPs for one slot depending on the SCS.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function cpDurations = scs2cps(scs)
    if (scs == 15)
        cpDurations = [160 144 144 144 144 144 144 160 144 144 144 144 144 144];
    elseif (scs == 30)
        cpDurations = [160 144 144 144 144 144 144 144 144 144 144 144 144 144];
    end
    cpDurations = cpDurations / sum(cpDurations) / scs;
end
