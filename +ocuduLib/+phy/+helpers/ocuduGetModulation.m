%ocuduGetModulation Returns the modulation scheme corresponding to a given Qm.
%   MODULATION = ocuduGetModulation(QM) returns the modulation scheme given a
%   specific modulation order QM (according to the 3GPP convention: i.e., the
%   number of bits per symbol).
%
%   [MODULATION, OCUDU] = ocuduGetModulation(QM) also returns the
%   modulation scheme according to OCUDU convention.
%
%   Remark: Setting QM = 1 returns 'pi/2-BPSK', not plain 'BPSK'.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [modulation, ocudumodulation] = ocuduGetModulation(Qm)
    switch Qm
        case 1
            modulation = 'pi/2-BPSK';
            ocudumodulation = 'PI_2_BPSK';
        case 2
            modulation = 'QPSK';
            ocudumodulation = 'QPSK';
        case 4
            modulation = '16QAM';
            ocudumodulation = 'QAM16';
        case 6
            modulation = '64QAM';
            ocudumodulation = 'QAM64';
        case 8
            modulation = '256QAM';
            ocudumodulation = 'QAM256';
        case 10
            modulation = '1024QAM';
            ocudumodulation = 'QAM1024';
        otherwise
            error('ocudu_matlab:ocuduGetModulation', ...
                'The supported modulation orders are (1, 2, 4, 6, 8, 10), provided %d', Qm);
    end

end
