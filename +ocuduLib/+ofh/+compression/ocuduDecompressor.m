%ocuduDecompressor Generation of a complex array from compressed input IQ data.
%   IQDATA = ocuduCompressor(CIQDATA, CPARAM, METHOD, CIQWIDTH)
%   decompresses the input compressed IQ data CIQDATA according to the
%   compression parameters for each PRB in CPARAM, the requested METHOD,
%   and input bit width CIQWIDTH and returns the IQ samples in IQDATA.
%
%   See also nrORANBlockDeompress.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function iqData = ocuduDecompressor(cIQData, cParam, method, cIQwidth)
    iqData = nrORANBlockDecompress(cIQData, cParam, method, cIQwidth, 16);
end
