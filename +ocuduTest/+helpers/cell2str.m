%cell2str Converts an any cell type value into a string.
%   OUTPUTSTRING = cell2str(ARG) converts the input INPUTCELL into its
%   character representation OUTPUTSTRING.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

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
