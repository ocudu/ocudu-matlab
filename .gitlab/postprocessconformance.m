%postprocessconformance Process conformance test results
%   postprocessconformance(RESULTS) analyzes the RESULTS of running a test suite
%   using the matlab.unittest framework and throws an exception if the number of
%   failures by assertions is larger than zero or if the number of failures by
%   verification is larger than the 10% of the total number of test results.
%
%   See also:
%       matlab.unittest.TestResults

%   Copyright 2021-2024 Software Radio Systems Limited
%
%   This file is part of srsRAN-matlab.
%
%   srsRAN-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   srsRAN-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

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
