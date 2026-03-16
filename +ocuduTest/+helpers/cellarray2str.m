%cellarray2str Converts any cell array type into a string.
%   OUTPUTSTRING = cellarray2str(ARG) converts the input INPUTCELLARRAY
%   into its character representation OUTPUTSTRING.
%    ISSTRUCT argument defines whether to use curly brackets wrapping OUTPUTSTRING

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function [outputString] = cellarray2str(inputCellArray, isStruct)
    import ocuduTest.helpers.cell2str
    import ocuduTest.helpers.cellarray2str

    if isStruct
        outputString = '{';
    else
        outputString = '';
    end

    % manage subcells within the input cell
    for arg = inputCellArray(1:end-1)
        outputString = [outputString, inputCell2str(arg), ', ']; %#ok<AGROW>
    end

    % Manage last element without appending colon.
    if ~isempty(inputCellArray)
      outputString = [outputString, inputCell2str(inputCellArray(end))];
    end

    if isStruct
        outputString = [outputString, '}'];
    end
end

function [outputString] = inputCell2str(inputCell)
    import ocuduTest.helpers.cell2str
    import ocuduTest.helpers.cellarray2str
    

    % manage subcells within the input cell
    if iscell(inputCell{1})
        outputString = cellarray2str(inputCell{1}(:)', true);
    else
        outputString = cell2str(inputCell);
    end
end
