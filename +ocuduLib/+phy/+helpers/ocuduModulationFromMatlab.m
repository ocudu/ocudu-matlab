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

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

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
        case '1024QAM'
            ocudumod = 'QAM1024';
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

