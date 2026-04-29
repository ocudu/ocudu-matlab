%input Overloads MATLAB input function.
%   input(~, ~, ANSWER) stores the content of ANSWER to be used as output for the
%   second form of the function (see below). ANSWER is a cell array containing all
%   the answer to successive calls of the input function.
%
%   RESULT = input(PROMPT) prompts for user input, as MATLAB's internal input
%   function, except that RESULT is taken from the previously recorded set of answers.
%
%   Example:
%
%      % Store a set of answers.
%      input('', '', {'hello', 34});
%      % Now simulate user interaction.
%      greeting = input('Common greeting: ');    % greeting is now 'hello'
%      fibo = input('Ninth Fibonacci number: '); % fibo is now 34
%
%   See also <a href="matlab:doc input">input</a>.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function v = input(~, ~, answer)
    persistent ANSWER i

    if nargin == 3
        ANSWER = answer;
        i = 1;
    else
        v = ANSWER{i};
        i = i + 1;
    end
end
