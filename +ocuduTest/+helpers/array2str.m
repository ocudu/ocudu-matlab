%array2str Converts an array of numeric values to a string.
%   OUTPUTSTRING = array2str(INPUTARRAY) converts the numeric array INPUTARRAY
%   into its character representation OUTPUTSTRING.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function outputString = array2str(inputArray)
    if isempty(inputArray)
        outputString = '{}';
        return;
    end

    tail = 1;
    if any(~isreal(inputArray))
        fmt = 'cf_t(%f, %f)';
        inputArray = inputArray(:); % ensure it's a row
        inputArray = reshape([real(inputArray).'; imag(inputArray).'], [], 1);
        tail = 2;
    elseif any(mod(inputArray,1) > 0)
        fmt = '%.3f';
    else
        fmt = '%d';
    end
    inputArray = inputArray(:).'; % ensure it's a row
    outputString = [num2str(inputArray(1:end-tail), [fmt, ', ']), ' ', num2str(inputArray(end-tail+1:end), fmt)];
end
