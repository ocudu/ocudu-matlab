%TrivialChannel Trivial, perfect channel.
%   CHAN = TrivialChannel creates a trivial (perfect link, no impairments) SIMO
%   channel System object, CHAN. This object simply creates a copy of the input
%   signal for each antenna at the receive side. The purpose of the class is to
%   provide a trivial SIMO channel with the same interface as MATLAB nrTDLChannel.
%
%   Step method syntax
%
%   Y = step(CHAN, X) generates the output matrix signal Y (one column per
%   receive antenna) by repeating the input column-vector signal X.
%
%   TrivialChannel methods:
%
%   step - Forwards input signal to all receive antennas.
%   info - Creates a structure with useful information about the TrivialChannel
%          object.
%
%   TrivialChannel properties:
%   NumReceiveAntennas - Number of receive antennas.
%   SampleRate         - Input signal sample rate (Hz).
%
%   See also nrTDLChannel, matlab.System.

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

classdef TrivialChannel < matlab.System
    properties (Nontunable)

        %Number of receive antennas.
        NumReceiveAntennas (1, 1) double {mustBePositive, mustBeInteger} = 1
        %Input signal sample rate (Hz).
        %   Only for compatibility purposes with nrTDPChannel.
        SampleRate (1, 1) double {mustBePositive, mustBeFinite} = 30720000
    end

    methods (Access = protected)
        function signalOut = stepImpl(obj, signalIn)
            arguments
                obj (1, 1) TrivialChannel
                %Input signal
                signalIn (:, 1) double
            end
            signalOut = repmat(signalIn, 1, obj.NumReceiveAntennas) / sqrt(obj.NumReceiveAntennas);
        end

        function channelInfo = infoImpl(obj)
            arguments
                obj (1, 1) TrivialChannel
            end

            channelInfo = struct(...
                'ChannelFilterDelay', 0, ...
                'MaximumChannelDelay', 0, ...
                'NumReceiveAntennas', obj.NumReceiveAntennas ...
                );
        end
    end % methods (Access = Protected)
end
