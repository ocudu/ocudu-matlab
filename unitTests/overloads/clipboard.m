%clipboard Overloads MATLAB clipboard function.
%   clipboard('', STUFF) stores the content of STUFF in an internal register.
%
%   STR =clipboard('paste') sets variable STR to the content of the internal
%   register (see above).
%
%   Example:
%
%      % Simulate copy-pasting from a system application to a variable.
%      % Store a string - simulates the copy step.
%      clipboard('', 'hello');
%      % Now simulate the pasting of the clipboard content into a variable.
%      greeting = clipboard('past');    % Now greeting is 'hello'.
%
%   See also <a href="matlab:doc clipboard">input</a>.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function str = clipboard(cmd, stuff)
    persistent LOG;

    if nargin == 2
        LOG = stuff;
    elseif strcmp(cmd, 'paste')
        str = LOG;
    else
        error('Operation not allowed.');
    end
end
