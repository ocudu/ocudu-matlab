%FormatDetailsF4 PUCCH Format 4 detail class for PUCCHPERF.
%
%   Helper class for the PUCCH performance simulator PUCCHPERF. It provides
%   metrics and method implementations specific for PUCCH Format 4 (most of them
%   are inherited from the FormatDetailsF2 class). The class is not meant to be
%   used outside PUCCHPERF.
%
%   FormatDetailsF4 properties (read-only):
%
%   SNRrange                  - SNR range in dB.
%   TotalBlocksCtr            - Counter of transmitted UCI messages.
%   BlockErrorRateMATLAB      - UCI block error rate (MATLAB case).
%   BlockErrorRateOCUDU       - UCI block error rate (OCUDU case).
%
%   See also PUCCHPERF, FormatDetailsF2.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef FormatDetailsF4 < FormatDetailsF2
    % This class is meant to be used only inside a PUCCHPERF simulation - restrict the constructor
    % and the methods that modify the properties.
    methods (Access = ?PUCCHPERF)
        function obj = FormatDetailsF4(nACKBits, nSRBits, nCSI1Bits, nCSI2Bits)
            % BLER tests work the same as detection tests.
            isdetection = true;
            obj@FormatDetailsF2(nACKBits, nSRBits, nCSI1Bits, nCSI2Bits, isdetection);
            obj.PUCCHFormat = 4;
        end % of function FormatDetailsF4(isdetection)
    end % of methods (Access = ?PUCCHPERF)

    methods (Static)
        function checkSymbolAllocation(symbolAllocation)
            if (symbolAllocation(2) < 4)
                error('PUCCH Format4 only allows the allocation of at least 4 OFDM symbols - requested %d.', symbolAllocation(2));
            end
        end

        function checkPRBs(nPRBs)
            if nPRBs ~= 1
                error ('PUCCH Format4 only allows one allocated PRB, given %d.', nPRBs);
            end
        end
    end % of methods (Static)
end % of classdef FormatDetailsF4 < FormatDetailsF2

