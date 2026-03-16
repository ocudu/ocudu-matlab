%matlab2ocuduPUCCHGroupHopping Generates a PUCCH group hopping string.
%   GROUPHOPPINGSTRING = matlab2ocuduPUCCHGroupHopping(GROUPHOPPING) returns a
%   string GROUPHOPPINGSTRING that is compliant with the C++ enum class element
%   used in OCUDU to identify the PUCCH group hopping type GROUPHOPPING.
%
%   See also nrPUCCH0Config, nrPUCCH1Config, nrPUCCH2Config, nrPUCCH3Config, nrPUCCH4Config.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function groupHoppingString = matlab2ocuduPUCCHGroupHopping(groupHopping)
    if strcmp(groupHopping, 'neither')
        type = 'NEITHER';
    elseif strcmp(groupHopping, 'enable')
        type = 'ENABLE';
    elseif strcmp(groupHopping, 'disable')
        type = 'DISABLE';
    else
        error('matlab2ocuduPUCCHGroupHopping:Invalid', 'Invalid PUCCH group hopping type.');
    end

    groupHoppingString = ['pucch_group_hopping::', type];
