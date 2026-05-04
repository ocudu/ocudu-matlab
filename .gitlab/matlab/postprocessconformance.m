%postprocessconformance Process conformance test results
%   postprocessconformance(RESULTS) analyzes the RESULTS of running a test suite
%   using the matlab.unittest framework and throws an exception if the number of
%   failures by assertions is larger than zero or if the number of failures by
%   verification is larger than the 10% of the total number of test results.
%
%   See also:
%       matlab.unittest.TestResults

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function postprocessconformance(testResults)
    arguments
        testResults (1, :) matlab.unittest.TestResult
    end

    failures = testResults([testResults.Failed]);

    nSoftFailures = 0;

    for thisFailure = failures
        failureEvents = {thisFailure.Details.DiagnosticRecord.Event};

        if strcmp(failureEvents{end}, 'AssertionFailed')
            ME = MException('conformance:assertionFound', 'No assertion failures allowed.');
            throw(ME);
        end

        if all(strcmp(failureEvents, 'VerificationFailed'))
            nSoftFailures = nSoftFailures + 1;
        else
            ME = MException('conformance:unkownEvent', ...
            'Event %s in not known.', failureEvents{1});
            throw(ME);
        end
    end

    nTests = length(testResults);
    assert(nSoftFailures < 0.5 * nTests, 'conformance:tooManyVerification', ...
        'At most 50%% of verification failures allowed: found %d out of %d.', nSoftFailures, nTests);
