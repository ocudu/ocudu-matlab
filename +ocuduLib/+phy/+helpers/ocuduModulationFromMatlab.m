%ocuduModulationFromMatlab Converts MATLAB modulation labels to OCUDU ones.
%   OCUDUMOD = ocuduModulationFromMatlab(MATLABMOD) returns the OCUDU modulation label
%   equivalent to the MATLAB modulation label MATLABMOD.
%
%   OCUDUMOD = ocuduModulationFromMatlab(MATLABMOD, 'full') prepends the modulation
%   label with the namespace 'modulation_scheme::'.
%
%   Examples
%      ocuduModulationFromMatlab('pi/2-BPSK')     % 'PI_2_BPSK'
%      ocuduModulationFromMatlab('QPSK', 'full')  % 'modulation_scheme::QPSK'

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

function ocudumod = ocuduModulationFromMatlab(matlabmod, fullname)
    switch matlabmod
        case 'pi/2-BPSK'
            ocudumod = 'PI_2_BPSK';
        case '16QAM'
            ocudumod = 'QAM16';
        case '64QAM'
            ocudumod = 'QAM64';
        case '256QAM'
            ocudumod = 'QAM256';
        case {'BPSK', 'QPSK'}
            ocudumod = matlabmod;
        otherwise
            error('ocudu_matlab:ocuduModulationFromMatlab', ...
                'Unknown modulation %s.', matlabmod);
    end

    if (nargin == 2) && strcmp(fullname, 'full')
        ocudumod = ['modulation_scheme::', ocudumod];
    end

end

