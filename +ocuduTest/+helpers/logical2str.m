%logical2str Convert logical to character representation.
%   T = logical2str(X) converts the logical X into its character representation
%   ('false' or 'true'). If X is a number, then T is the character representation
%   of X > 0.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function logicString = logical2str(input)
    strings = {'false', 'true'};
    logicString = strings{1 + (input > 0)};
