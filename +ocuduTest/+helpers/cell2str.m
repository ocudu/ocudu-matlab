%cell2str Converts an any cell type value into a string.
%   OUTPUTSTRING = cell2str(ARG) converts the input INPUTCELL into its
%   character representation OUTPUTSTRING.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [outoutString] = cell2str(inputCell)
    import ocuduTest.helpers.array2str

    mat = cell2mat(inputCell);

    if isstring(inputCell) || iscellstr(inputCell)
        outoutString = mat;
    elseif isscalar(mat)
        if islogical(mat)
            outoutString = char(string(mat));
        else
            outoutString = num2str(mat);
        end
    else
        outoutString = ['{', array2str(mat), '}'];
    end
end
