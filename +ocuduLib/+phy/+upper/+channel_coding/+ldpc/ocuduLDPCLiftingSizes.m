%ocuduLDPCLiftingSizes List of all valid lifting sizes.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function liftSizes = ocuduLDPCLiftingSizes
    liftSizes = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
