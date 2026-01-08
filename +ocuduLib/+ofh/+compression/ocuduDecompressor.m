%ocuduDecompressor Generation of a complex array from compressed input IQ data.
%   IQDATA = ocuduCompressor(CIQDATA, CPARAM, METHOD, CIQWIDTH)
%   decompresses the input compressed IQ data CIQDATA accordig to the
%   compression parameters for each PRB in CPARAM, the requested METHOD, 
%   and input bit width CIQWIDTH and returns the IQ samples in IQDATA.
%
%   See also nrORANBlockDeompress.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function iqData = ocuduDecompressor(cIQData, cParam, method, cIQwidth)
    iqData = nrORANBlockDecompress(cIQData, cParam, method, cIQwidth, 16);
end
