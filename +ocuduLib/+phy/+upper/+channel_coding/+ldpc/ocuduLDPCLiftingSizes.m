%ocuduLDPCLiftingSizes List of all valid lifting sizes.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function liftSizes = ocuduLDPCLiftingSizes
    liftSizes = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
