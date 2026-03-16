%ocuduPRACHDetector MATLAB interface to OCUDU PRACH detector.
%   User-friendly interface to the OCUDU PRACH detector class, which is wrapped
%   by the MEX static method prach_detector_mex.
%
%   PRACHDETECTOR = ocuduPRACHDetector creates a PHY PRACH Detector object.
%
%   ocuduPRACHDetector Methods:
%
%   step               - Detects a PRACH preamble (if any is present).
%
%   Step method syntax
%
%   DETECTIONRESULTS = step(PRACHDETECTOR, PRACH, SYMBOLS) uses
%   the object PRACHDETECTOR to detect a PRACH preamble in the frequency-domain
%   signal SYMBOLS and returns the detection results DETECTIONRESULTS.
%
%   PRACH is a PRACH configuration object, nrPRACHConfig. Only these object properties
%   are relevant for this function:
%      Format                - the PRACH preamble format;
%      SequenceIndex         - the root sequence index;
%      RestrictedSet         - the restricted set configuration;
%      ZeroCorrelationZone   - the zero correlation zone configuration index;
%      SubcarrierSpacing     - the PRACH subcarrier spacing.
%
%   SYMBOLS is a complex array which comprises the outputs of the PRACH
%   demodulator stage.
%
%   Structure DETECTIONRESULTS provides the PRACH detection results. The
%   fields are
%      NumDetectedPreambles - number of detected PRACH preambles;
%      RSSIDecibel          - average RSSI value in dB;
%      TimeResolution       - detector time resolution;
%      MaxTimeAdvance       - detector maximum tolerated time advance;
%      PreambleIndices      - array of indices of the detected PRACH preambles;
%      TimeAdvance          - array of timing advance values in seconds between the observed arrival time
%                             (for the corresponding preamble indices) and the reference uplink time;
%      NormalizedMetric     - array of detection metrics, normalized with respect to the
%                             detection threshold.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

classdef ocuduPRACHDetector < matlab.System
    methods (Access = protected)
        function PRACHdetectionResult = stepImpl(obj, prach, symbols)
            arguments
                obj     (1, 1)    ocuduMEX.phy.ocuduPRACHDetector
                prach   (1, 1)    nrPRACHConfig
                symbols (:, :, :) double
            end

            PRACHCfg = struct(...
                'Format', prach.Format, ...
                'SequenceIndex', prach.SequenceIndex, ...
                'RestrictedSet', prach.RestrictedSet, ...
                'ZeroCorrelationZone', prach.ZeroCorrelationZone, ...
                'SubcarrierSpacing', prach.SubcarrierSpacing ...
                );

            PRACHdetectionResult = obj.prach_detector_mex('step', symbols, PRACHCfg);
        end % function step(...)
    end % of methods (Access = protected)

    methods (Access = private, Static)
        %MEX function doing the actual work. See the Doxygen documentation.
        varargout = prach_detector_mex(varargin)
    end % of methods (Access = private)

end % of classdef ocuduPRACHDetector < matlab.System
