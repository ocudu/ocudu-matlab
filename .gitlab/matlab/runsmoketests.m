function runsmoketests(testtag, filename)
%runsmoketests executes the 'run matlab unit tests' or the 'mex basic tests' CI job.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
    arguments
        testtag     char {mustBeTextScalar};
        filename    char {mustBeTextScalar};
    end

    % Create a test runner with the XML plugin to record a J-Unit report of the
    % tests in 'filename.'
    runner = testrunner();
    plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(filename, "OutputDetail", "terse");
    addPlugin(runner, plugin);

    % Run all specified tests.
    smokeTests = testsuite("tests/smoke", Tag=testtag);
    assertSuccess(run(runner, smokeTests));
end
