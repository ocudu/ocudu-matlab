%ocuduCompressor Generation of compressed IQ data from a complex input array.
%   [CIQDATA, CPARAM] = ocuduCompressor(IQDATA, METHOD, CIQWIDTH)
%   compresses the input IQ samples accordig to the requested METHOD and
%   output bit width CIQWIDTH and returns the compressed IQ samples 
%   in CIQDATA and compression parameters for each PRB in CPARAM.
%
%   See also nrORANBlockCompress.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [cIQData, cParam] = ocuduCompressor(iqData, method, cIQwidth)
    [cIQData, cParam] = nrORANBlockCompress(iqData, method, cIQwidth, 16);
end
