%ocuduCompressor Generation of compressed IQ data from a complex input array.
%   [CIQDATA, CPARAM] = ocuduCompressor(IQDATA, METHOD, CIQWIDTH)
%   compresses the input IQ samples according to the requested METHOD and
%   output bit width CIQWIDTH and returns the compressed IQ samples
%   in CIQDATA and compression parameters for each PRB in CPARAM.
%
%   See also nrORANBlockCompress.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [cIQData, cParam] = ocuduCompressor(iqData, method, cIQwidth)
    [cIQData, cParam] = nrORANBlockCompress(iqData, method, cIQwidth, 16);
end
