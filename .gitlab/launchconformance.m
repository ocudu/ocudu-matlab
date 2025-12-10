%launchconformance Launch conformance tests
%   RESULTS = launchconformance(TESTS, EXPRESSION) launches the subset of TESTS
%   whose name matches the given regular EXPRESSION. It returns the test results.
%
%   See also:
%       matlab.unittest.TestSuite, regexp

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

function testResults = launchconformance(tests, expression)
    arguments
        tests (1, :) char
        expression (1, :) char
    end

    import matlab.unittest.selectors.HasName
    import matlab.unittest.constraints.Matches

    allTests = testsuite(tests, Tag='conformance');
    selectedTests = selectIf(allTests, HasName(Matches(expression)));

    testResults = run(selectedTests);
