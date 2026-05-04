function runvectortests(testtag, israndom, filename, artifactdir)
%runvectortests executes the 'build test vectors' or the 'build mex full tests' CI job.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
    arguments
        testtag           char     {mustBeTextScalar}
        israndom   (1, 1) logical
        filename          char     {mustBeTextScalar}
        artifactdir       char     {mustBeFolder} = "/tmp"
    end

    % Create a test suite with all the tagged tests and a runner.
    [allTests, runner] = runOCUDUunittest("all", testtag, RandomShuffle=israndom);

    % Create an XML plugin to record a J-Unit report of the tests in 'filename.'
    plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(filename, "OutputDetail", "terse");
    addPlugin(runner, plugin);

    % Run all specified tests.
    testresults = runner.run(allTests);

    if strcmp(testtag, "testvector")
        ocuduTest.copyOCUDUtestvectors("testvectorOutputs", artifactdir);
    end

    assertSuccess(testresults)
end
