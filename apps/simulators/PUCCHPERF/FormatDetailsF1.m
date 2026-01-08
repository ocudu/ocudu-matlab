%FormatDetailsF1 PUCCH Format 1 detail class for PUCCHPERF.
%
%   Helper class for the PUCCH performance simulator PUCCHPERF. It provides
%   metrics and method implementations specific for PUCCH Format 1. The class
%   is not meant to be used outside PUCCHPERF.
%
%   FormatDetailsF1 properties (read-only):
%
%   SNRrange                      - SNR range in dB.
%   TransmittedACKsCtr            - Counter of tranmsitted ACK bits.
%   TransmittedNACKsCtr           - Counter of transmitted NACKs.
%   ACKOccasionsCtr               - Counter of ACK occasions.
%   MissedOccasionsMATLABCtr      - Counter of missed occasions (MATLAB case).
%   MissedOccasionsOCUDUCtr       - Counter of missed occasions (OCUDU case).
%   MissedACKsMATLABCtr           - Counter of missed ACK bits (MATLAB case).
%   MissedACKsOCUDUCtr            - Counter of missed ACK bits (OCUDU case).
%   NACK2ACKsMATLABCtr            - Counter of NACK bits received as ACK bits (MATLAB case).
%   NACK2ACKsOCUDUCtr             - Counter of NACK bits received as ACK bits (OCUDU case).
%   FalseACKsMATLABCtr            - Counter of false ACK bits (MATLAB case).
%   FalseACKsOCUDUCtr             - Counter of false ACK bits (OCUDU case).
%   PUCCHDetectionRateMATLAB      - Detection rate of PUCCH F1 transmissions (MATLAB case).
%   PUCCHDetectionRateOCUDU       - Detection rate of PUCCH F1 transmissions (OCUDU case).
%   FalseACKDetectionRateMATLAB   - False ACK detection rate (MATLAB case).
%   FalseACKDetectionRateOCUDU    - False ACK detection rate (OCUDU case).
%   NACK2ACKDetectionRateMATLAB   - NACK-to-ACK detection rate (MATLAB case).
%   NACK2ACKDetectionRateOCUDU    - NACK-to-ACK detection rate (OCUDU case).
%   ACKDetectionRateMATLAB        - ACK Detection rate (MATLAB case).
%   ACKDetectionRateOCUDU         - ACK Detection rate (OCUDU case).
%
%   See also PUCCHPERF.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef FormatDetailsF1 < handle
    properties (SetAccess = private)
        %SNR range in dB.
        SNRrange = []
        %Counter of tranmsitted ACK bits.
        TransmittedACKsCtr = []
        %Counter of transmitted NACKs.
        TransmittedNACKsCtr = []
        %Counter of ACK occasions.
        ACKOccasionsCtr = []
        %Counter of missed occasions (MATLAB case).
        MissedOccasionsMATLABCtr = []
        %Counter of missed occasions (OCUDU case).
        MissedOccasionsOCUDUCtr = []
        %Counter of missed ACK bits (MATLAB case).
        MissedACKsMATLABCtr = []
        %Counter of missed ACK bits (OCUDU case).
        MissedACKsOCUDUCtr = []
        %Counter of NACK bits received as ACK bits (MATLAB case).
        NACK2ACKsMATLABCtr = []
        %Counter of NACK bits received as ACK bits (OCUDU case).
        NACK2ACKsOCUDUCtr = []
        %Counter of false ACK bits (MATLAB case).
        FalseACKsMATLABCtr = []
        %Counter of false ACK bits (OCUDU case).
        FalseACKsOCUDUCtr = []
    end % of properties (SetAccess = private)

    properties (Dependent)
        %False ACK detection rate (MATLAB case).
        %   Probability of detecting an ACK when the input is only noise (or DTX).
        FalseACKDetectionRateMATLAB
        %False ACK detection rate (OCUDU case).
        %   Probability of detecting an ACK when the input is only noise (or DTX).
        FalseACKDetectionRateOCUDU
        %NACK-to-ACK detection rate (MATLAB case).
        %   Probability of detecting an ACK when a NACK is transmitted.
        NACK2ACKDetectionRateMATLAB
        %NACK-to-ACK detection rate (OCUDU case).
        %   Probability of detecting an ACK when a NACK is transmitted.
        NACK2ACKDetectionRateOCUDU
        %ACK Detection rate (MATLAB case).
        %   Probability of detecting an ACK when the ACK is transmitted.
        ACKDetectionRateMATLAB
        %ACK Detection rate (OCUDU case).
        %   Probability of detecting an ACK when the ACK is transmitted.
        ACKDetectionRateOCUDU
        %Transmission detection rate (MATLAB case).
        %   Probability of detecting a PUCCH F1 when the PUCCH F1 is transmitted.
        PUCCHDetectionRateMATLAB
        %Transmission detection rate (OCUDU case).
        %   Probability of detecting a PUCCH F1 when the PUCCH F1 is transmitted.
        PUCCHDetectionRateOCUDU
    end % of properties (Dependable)

    properties (Hidden)
        %Boolean flag test type: true if strcmp(TestType, 'Detection'), false otherwise.
        isDetectionTest
        %Number of HARQ-ACK bits.
        NumACKBits
        %Number of SR bits.
        NumSRBits
    end % of properties (Hidden)

    % This class is meant to be used only inside a PUCCHPERF simulation - restrict the constructor
    % and the methods that modify the properties.
    methods (Access = ?PUCCHPERF)
        function obj = FormatDetailsF1(nACKBits, nSRBits, isdetection)
            obj.NumACKBits = nACKBits;
            obj.NumSRBits = nSRBits;
            obj.isDetectionTest = isdetection;
        end % of function FormatDetailsF1(nACKBits, nSRBits, isdetection)

        function reset(obj)
            obj.SNRrange = [];
            obj.TransmittedACKsCtr = [];
            obj.TransmittedNACKsCtr = [];
            obj.ACKOccasionsCtr = [];
            obj.MissedOccasionsMATLABCtr = [];
            obj.MissedOccasionsOCUDUCtr = [];
            obj.MissedACKsMATLABCtr = [];
            obj.MissedACKsOCUDUCtr = [];
            obj.FalseACKsMATLABCtr = [];
            obj.FalseACKsOCUDUCtr = [];
        end

        function updateCounters(obj, stats, SNRIn, ~)
            [~, repeatedIdx] = intersect(obj.SNRrange, SNRIn(:));
            obj.SNRrange(repeatedIdx) = [];
            [obj.SNRrange, sortedIdx] = sort([obj.SNRrange; SNRIn(:)]);

            obj.ACKOccasionsCtr = joinArrays(obj.ACKOccasionsCtr, stats.nOccasions, repeatedIdx, sortedIdx);

            if obj.isDetectionTest
                obj.TransmittedACKsCtr = joinArrays(obj.TransmittedACKsCtr, stats.nACKs, repeatedIdx, sortedIdx);
                obj.TransmittedNACKsCtr = joinArrays(obj.TransmittedNACKsCtr, stats.nNACKs, repeatedIdx, sortedIdx);
                obj.MissedACKsMATLABCtr = joinArrays(obj.MissedACKsMATLABCtr, stats.missedACK, repeatedIdx, sortedIdx);
                obj.MissedACKsOCUDUCtr = joinArrays(obj.MissedACKsOCUDUCtr, stats.missedACKOCUDU, repeatedIdx, sortedIdx);
                obj.NACK2ACKsMATLABCtr = joinArrays(obj.NACK2ACKsMATLABCtr, stats.NACK2ACK, repeatedIdx, sortedIdx);
                obj.NACK2ACKsOCUDUCtr = joinArrays(obj.NACK2ACKsOCUDUCtr, stats.NACK2ACKOCUDU, repeatedIdx, sortedIdx);
                obj.MissedOccasionsMATLABCtr = joinArrays(obj.MissedOccasionsMATLABCtr, stats.missedPUCCH, repeatedIdx, sortedIdx);
                obj.MissedOccasionsOCUDUCtr = joinArrays(obj.MissedOccasionsOCUDUCtr, stats.missedPUCCHOCUDU, repeatedIdx, sortedIdx);
            else
                obj.FalseACKsMATLABCtr = joinArrays(obj.FalseACKsMATLABCtr, stats.falseACK, repeatedIdx, sortedIdx);
                obj.FalseACKsOCUDUCtr = joinArrays(obj.FalseACKsOCUDUCtr, stats.falseACKOCUDU, repeatedIdx, sortedIdx);
            end
        end % of function updateCounters(obj)
    end

    methods (Static)
        function checkSymbolAllocation(symbolAllocation)
            if symbolAllocation(2) < 4
                error('PUCCH Format1 only allows the allocation of a number of OFDM symbols in the range 4-14 - requested %d.', ...
                    symbolAllocation(2));
            end
        end

        function checkPRBs(nPRBs)
            if nPRBs ~= 1
                error ('PUCCH Format1 only allows one allocated PRB, given %d.', nPRBs);
            end
        end

        function checkUCIBits(NumACKBits, NumSRBits, NumCSI1Bits, NumCSI2Bits)
            if (NumSRBits > 0) || (NumCSI1Bits > 0) || (NumCSI2Bits > 0)
                error(['For PUCCH Format1, only ACK bits are allowed. '...
                    'Provided SR: %d, CSI Part1: %d, CSI Part2: %d.'], ...
                    NumSRBits, NumCSI1Bits, NumCSI2Bits);
            end
            if NumACKBits > 2
                error(['For PUCCH Format1, maximum 2 HARQ-ACK bits are allowed. '...
                    'Provided %d.'], NumACKBits);
            end
        end

        % Creates a temporary structure of metrics to collect data for the current simulation.
        function stats = setupTmpStats(nPoints)
            stats = struct(...
                'missedPUCCH', zeros(nPoints, 1), ...       % number of MATLAB non-detected PUCCH transmissions
                'missedACK', zeros(nPoints, 1), ...         % number of MATLAB missed ACKs
                'NACK2ACK', zeros(nPoints, 1), ...          % number of MATLAB NACKs received as ACKs
                'falseACK', zeros(nPoints, 1), ...          % number of MATLAB false ACKs
                'missedPUCCHOCUDU', zeros(nPoints, 1), ...  % number of OCUDU non-detected PUCCH transmissions
                'missedACKOCUDU', zeros(nPoints, 1), ...    % number of OCUDU missed ACKs
                'NACK2ACKOCUDU', zeros(nPoints, 1), ...     % number of OCUDU NACKs received as ACKs
                'falseACKOCUDU', zeros(nPoints, 1), ...     % number of OCUDU false ACKs
                'nACKs', zeros(nPoints, 1), ...             % number of transmitted ACKs
                'nNACKs', zeros(nPoints, 1), ...            % number of transmitted NACKs
                'nOccasions', zeros(nPoints, 1) ...         % number of ACK occasions
                );
        end

        function stats = updateStatsMATLAB(stats, uci, uciRx, ~, isDetectTest, snrIdx)
            if isDetectTest
                % If MATLAB's PUCCH decoder was able to detect a PUCCH and
                % uciRx contains the resulting bits.
                if ~isempty(uciRx{1})
                    % NACK to ACK.
                    stats.NACK2ACK(snrIdx) = stats.NACK2ACK(snrIdx) + sum(~uci & uciRx{1});
                    % Missed ACK.
                    stats.missedACK(snrIdx) = stats.missedACK(snrIdx) + sum(uci & ~uciRx{1});
                else
                    % Record a non-detected PUCCH F1 transmission.
                    stats.missedPUCCH(snrIdx) = stats.missedPUCCH(snrIdx) + 1;
                    % Missed ACK. Here, uciRx is empty (MATLAB's PUCCH decoder failed
                    % to detect) and all ACKs are lost.
                    stats.missedACK(snrIdx) = stats.missedACK(snrIdx) + sum(uci);
                end
            else % false alarm test
                % False ACK.
                stats.falseACK(snrIdx) = stats.falseACK(snrIdx) + sum(uciRx{1});
            end % if isDetectTest
        end

        function stats = updateStatsOCUDU(stats, uci, msg, isDetectTest, snrIdx)
            uciRxOCUDU = msg.HARQAckPayload;
            if isDetectTest
                % If OCUDU's PUCCH decoder was able to detect a PUCCH.
                if msg.isValid
                    % NACK to ACK.
                    stats.NACK2ACKOCUDU(snrIdx) = stats.NACK2ACKOCUDU(snrIdx) + sum(~uci & uciRxOCUDU);
                    % Missed ACK.
                    stats.missedACKOCUDU(snrIdx) = stats.missedACKOCUDU(snrIdx) + sum(uci & ~uciRxOCUDU);
                else
                    % Record a non-detected PUCCH F1 transmission.
                    stats.missedPUCCHOCUDU(snrIdx) = stats.missedPUCCHOCUDU(snrIdx) + 1;
                    % Missed ACK. Here, OCUDU's PUCCH decoder failed
                    % to detect and all ACKs are lost.
                    stats.missedACKOCUDU(snrIdx) = stats.missedACKOCUDU(snrIdx) + sum(uci);
                end
            else % false alarm test
                % False ACK.
                if msg.isValid
                    stats.falseACKOCUDU(snrIdx) = stats.falseACKOCUDU(snrIdx) + sum(uciRxOCUDU);
                end
            end
        end

        function printMessagesMATLAB(stats, usedFrames, ~, SNRIn, isDetectTest, snrIdx)
            if isDetectTest
                fprintf(['PUCCH Format 1 - Missed transmission rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.missedPUCCH(snrIdx)/stats.nOccasions(snrIdx));
                fprintf(['PUCCH Format 1 - NACK to ACK rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.NACK2ACK(snrIdx)/stats.nNACKs(snrIdx));
                fprintf(['PUCCH Format 1 - ACK missed detection rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.missedACK(snrIdx)/stats.nACKs(snrIdx));
            else
                fprintf(['PUCCH Format 1 - false ACK detection rate for %d frame(s) at ', ...
                'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.falseACK(snrIdx)/stats.nOccasions(snrIdx));
            end
        end

        function printMessagesOCUDU(stats, usedFrames, ~, SNRIn, isDetectTest, snrIdx)
            if isDetectTest
                fprintf(['OCUDU - PUCCH Format 1 - Missed transmission rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.missedPUCCHOCUDU(snrIdx)/stats.nOccasions(snrIdx));
                fprintf(['OCUDU - PUCCH Format 1 - NACK to ACK rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.NACK2ACKOCUDU(snrIdx)/stats.nNACKs(snrIdx));
                fprintf(['OCUDU - PUCCH Format 1 - ACK missed detection rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.missedACKOCUDU(snrIdx)/stats.nACKs(snrIdx));
            else
                fprintf(['OCUDU - PUCCH Format 1 - false ACK detection rate for %d frame(s) at ', ...
                    'SNR %.1f dB: %g\n'], usedFrames, SNRIn(snrIdx), stats.falseACKOCUDU(snrIdx)/stats.nOccasions(snrIdx));
            end
        end
    end % of methods (Static)

    methods
        function fdr = get.FalseACKDetectionRateMATLAB(obj)
            if obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The FalseACKDetectionRateMATLAB property is inactive when TestType == ''Detection''.');
                warning('on', 'backtrace');
                fdr = [];
                return
            end
            fdr = obj.FalseACKsMATLABCtr ./ obj.ACKOccasionsCtr;
        end

        function fdr = get.FalseACKDetectionRateOCUDU(obj)
            if obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The FalseACKDetectionRateOCUDU property is inactive when TestType == ''Detection''.');
                warning('on', 'backtrace');
                fdr = [];
                return
            end
            fdr = obj.FalseACKsOCUDUCtr ./ obj.ACKOccasionsCtr;
        end

        function n2a = get.NACK2ACKDetectionRateMATLAB(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The NACK2ACKDetectionRateMATLAB property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                n2a = [];
                return
            end
            n2a = obj.NACK2ACKsMATLABCtr ./ obj.TransmittedNACKsCtr;
        end

        function n2a = get.NACK2ACKDetectionRateOCUDU(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The NACK2ACKDetectionRateOCUDU property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                n2a = [];
                return
            end
            n2a = obj.NACK2ACKsOCUDUCtr ./ obj.TransmittedNACKsCtr;
        end

        function ackd = get.ACKDetectionRateMATLAB(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The ACKDetectionRateMATLAB property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                ackd = [];
                return
            end
            ackd = 1 - obj.MissedACKsMATLABCtr ./ obj.TransmittedACKsCtr;
        end

        function ackd = get.ACKDetectionRateOCUDU(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The ACKDetectionRateOCUDU property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                ackd = [];
                return
            end
            ackd = 1 - obj.MissedACKsOCUDUCtr ./ obj.TransmittedACKsCtr;
        end

        function pucchd = get.PUCCHDetectionRateMATLAB(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The PUCCHDetectionRateMATLAB property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                pucchd = [];
                return
            end
            pucchd = 1 - obj.MissedOccasionsMATLABCtr ./ obj.ACKOccasionsCtr;
        end

        function pucchd = get.PUCCHDetectionRateOCUDU(obj)
            if ~obj.isDetectionTest
                warning('off', 'backtrace');
                warning('The PUCCHDetectionRateOCUDU property is inactive when TestType == ''False Alarm''.');
                warning('on', 'backtrace');
                pucchd = [];
                return
            end
            pucchd = 1 - obj.MissedOccasionsOCUDUCtr ./ obj.ACKOccasionsCtr;
        end

        function flag = hasresults(obj)
            flag = ~isempty(obj.SNRrange);
        end

        function [codedUCI, stats] = UCIEncode(obj, uci, ouci, ~, stats, snrIdx)
            % For Format1, no encoding.
            codedUCI = uci;

            stats.nOccasions(snrIdx) = stats.nOccasions(snrIdx) + ouci;

            if obj.isDetectionTest
                stats.nACKs(snrIdx) = stats.nACKs(snrIdx) + sum(uci);
                stats.nNACKs(snrIdx) = stats.nNACKs(snrIdx) + sum(~uci);
            end
        end % of function UCIEncode()

        function counts = getCounters(obj, implementationType)
            counts = struct();
            counts.SNRrange = obj.SNRrange;
            counts.ACKOccasionsCtr = obj.ACKOccasionsCtr;

            getMatlab = ~strcmp(implementationType, 'ocudu');
            getOCUDU = ~strcmp(implementationType, 'matlab');
            if obj.isDetectionTest
                counts.TransmittedACKsCtr = obj.TransmittedACKsCtr;
                counts.TransmittedNACKsCtr = obj.TransmittedNACKsCtr;
                if getOCUDU
                    counts.MissedOccasionsOCUDUCtr = obj.MissedOccasionsOCUDUCtr;
                    counts.MissedACKsOCUDUCtr = obj.MissedACKsOCUDUCtr;
                    counts.NACK2ACKsOCUDUCtr = obj.NACK2ACKsOCUDUCtr;
                end
                if getMatlab
                    counts.MissedOccasionsMATLABCtr = obj.MissedOccasionsMATLABCtr;
                    counts.MissedACKsMATLABCtr = obj.MissedACKsMATLABCtr;
                    counts.NACK2ACKsMATLABCtr = obj.NACK2ACKsMATLABCtr;
                end
            else
                if getOCUDU
                    counts.FalseACKsOCUDUCtr = obj.FalseACKsOCUDUCtr;
                end
                if getMatlab
                    counts.FalseACKsMATLABCtr = obj.FalseACKsMATLABCtr;
                end
            end
        end % of function getCounters(obj)

        function statistics = getStatistics(obj, implementationType)
            statistics = struct();

            getMatlab = ~strcmp(implementationType, 'ocudu');
            getOCUDU = ~strcmp(implementationType, 'matlab');
            if obj.isDetectionTest
                if getOCUDU
                    statistics.ACKDetectionRateOCUDU = obj.ACKDetectionRateOCUDU;
                    statistics.NACK2ACKDetectionRateOCUDU = obj.NACK2ACKDetectionRateOCUDU;
                    statistics.PUCCHDetectionRateOCUDU = obj.PUCCHDetectionRateOCUDU;
                end
                if getMatlab
                    statistics.ACKDetectionRateMATLAB = obj.ACKDetectionRateMATLAB;
                    statistics.NACK2ACKDetectionRateMATLAB = obj.NACK2ACKDetectionRateMATLAB;
                    statistics.PUCCHDetectionRateMATLAB = obj.PUCCHDetectionRateMATLAB;
                end
            else
                if getOCUDU
                    statistics.FalseACKDetectionRateOCUDU = obj.FalseACKDetectionRateOCUDU;
                end
                if getMatlab
                    statistics.FalseACKDetectionRateMATLAB = obj.FalseACKDetectionRateMATLAB;
                end
            end
        end % of function getStatistics(obj)

        function flag = isSimOver(obj, stats, snrIdx, implementationType)
            useMATLAB = ~strcmp(implementationType, 'ocudu');
            useOCUDU = ~strcmp(implementationType, 'matlab');

            if obj.isDetectionTest
                isSimOverMATLAB = (stats.missedACK(snrIdx) >= 100) && (stats.NACK2ACK(snrIdx) >= 100);
                isSimOverOCUDU = (stats.missedACKOCUDU(snrIdx) >= 100) && (stats.NACK2ACKOCUDU(snrIdx) >= 100);
            else
                isSimOverMATLAB = (stats.falseACK(snrIdx) >= 100);
                isSimOverOCUDU = (stats.falseACKOCUDU(snrIdx) >= 100);
            end
            isSimOverMATLAB = ~useMATLAB || isSimOverMATLAB;
            isSimOverOCUDU = ~useOCUDU || isSimOverOCUDU;

            flag = isSimOverMATLAB && isSimOverOCUDU;
        end

        function plot(obj, implementationType, subcarrierSpacing)

            plotMATLAB = (strcmp(implementationType, 'matlab') || strcmp(implementationType, 'both'));
            plotOCUDU = (strcmp(implementationType, 'ocudu') || strcmp(implementationType, 'both'));

            titleString = sprintf('PUCCH F1 / SCS=%dkHz / %d ACK bits', subcarrierSpacing, obj.NumACKBits);
            legendstrings = {};

            figure;
            set(gca, "YScale", "log")
            if plotMATLAB
                if obj.isDetectionTest
                    semilogy(obj.SNRrange, obj.NACK2ACKsMATLABCtr ./ obj.TransmittedNACKsCtr, 'o-.', ...
                        'LineWidth', 1, 'Color', [0 0.4470 0.7410]);
                    legendstrings{end + 1} = 'MATLAB - NACK to ACK';

                    hold on;
                    semilogy(obj.SNRrange, obj.MissedACKsMATLABCtr ./ obj.TransmittedACKsCtr, 'square:', ...
                        'LineWidth', 1, 'Color', [0 0.4470 0.7410]);
                    legendstrings{end + 1} = 'MATLAB - Missed ACK';
                    hold off;
                else
                    semilogy(obj.SNRrange, obj.FalseACKsMATLABCtr ./ obj.ACKOccasionsCtr, 'o-.', ...
                        'LineWidth', 1, 'Color', [0 0.4470 0.7410]);
                    legendstrings{end + 1} = 'MATLAB - False ACK';
                end
            end

            if plotOCUDU
                hold on;
                if obj.isDetectionTest
                    semilogy(obj.SNRrange, obj.NACK2ACKsOCUDUCtr ./ obj.TransmittedNACKsCtr, 'o-.', ...
                        'LineWidth', 1, 'Color', [0.8500 0.3250 0.0980]);
                    legendstrings{end + 1} = 'OCUDU - NACK to ACK';

                    semilogy(obj.SNRrange, obj.MissedACKsOCUDUCtr ./ obj.TransmittedACKsCtr, 'square:', ...
                        'LineWidth', 1, 'Color', [0.8500 0.3250 0.0980]);
                    legendstrings{end + 1} = 'OCUDU - Missed ACK';
                else
                    semilogy(obj.SNRrange, obj.FalseACKsOCUDUCtr ./ obj.ACKOccasionsCtr, 'o-.', ...
                        'LineWidth', 1, 'Color', [0.8500 0.3250 0.0980]);
                    legendstrings{end + 1} = 'OCUDU - False ACK';
                end
                hold off;
            end

            xlabel('SNR (dB)'); ylabel('Probability'); grid on; legend(legendstrings);
            title(titleString);
        end % of function plot(obj, implementationType, subcarrierSpacing)

    end % of methods
end % of classdef FormatDetailsF1
