%launchconformance Launch conformance tests
%   RESULTS = launchconformance(TESTS, EXPRESSION) launches the subset of TESTS
%   whose name matches the given regular EXPRESSION. It returns the test results.
%
%   See also:
%       matlab.unittest.TestSuite, regexp

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

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
