function testResults = launchconformance(tests, expression, filename)
%launchconformance Launch conformance tests
%   RESULTS = launchconformance(TESTS, EXPRESSION) launches the subset of TESTS
%   whose name matches the given regular EXPRESSION. It returns the test results.
%
%   See also:
%       matlab.unittest.TestSuite, regexp

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
    arguments
        tests           char {mustBeTextScalar}
        expression      char {mustBeTextScalar}
        filename        char {mustBeTextScalar}
    end

    import matlab.unittest.selectors.HasName
    import matlab.unittest.constraints.Matches

    allTests = testsuite(tests, Tag='conformance');
    selectedTests = selectIf(allTests, HasName(Matches(expression)));

    % Create a test runner with the XML plugin to record a J-Unit report of the
    % tests in 'filename.'
    runner = testrunner();
    plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(filename, "OutputDetail", "detail");
    addPlugin(runner, plugin);

    testResults = run(runner, selectedTests);
