%scs2cps Returns the duration (in ms) of the CPs for one slot depending on the SCS.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function cpDurations = scs2cps(scs)
    % See TS38.211 Section 5.3.1 for details.
    if (scs == 15)
        % When SCS = 15 kHz, the CP is 160 kappa for symbols 0 and 7, and 144 kappa
        % for the remaining symbols.
        cpDurations = [160 144 144 144 144 144 144 160 144 144 144 144 144 144];
    elseif (scs == 30)
        % When SCS = 30 kHz, the CP is 88 kappa for symbols 0 and 14, and 72 kappa
        % for the remaining symbols. Here, we only focus on the first slot in the
        % subframe.
        cpDurations = [88 72 72 72 72 72 72 72 72 72 72 72 72 72];
    elseif ((scs == 30) || (scs == 120))
        % When SCS = 120 kHz, the CP is 34 kappa for symbols 0 and 56, and 18 kappa
        % for the remaining symbols. Here, we only focus on the first slot in the
        % subframe.
        cpDurations = [34 18 18 18 18 18 18 18 18 18 18 18 18 18];
    else
        error('ocudu_matlab:scs2cps', 'Unsupported subcarrierspacing %d kHz.', scs);
    end
    cpDurations = cpDurations / sum(cpDurations) / scs;
end
