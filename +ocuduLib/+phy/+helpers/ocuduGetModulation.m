%ocuduGetModulation Returns the modulation scheme corresponding to a given Qm.
%   MODULATION = ocuduGetModulation(QM) returns the modulation scheme given a
%   specific modulation order QM (according to the 3GPP convention: i.e., the
%   number of bits per symbol).
%
%   [MODULATION, OCUDU] = ocuduGetModulation(QM) also returns the
%   modulation scheme according to OCUDU convention.
%
%   Remark: Setting QM = 1 returns 'pi/2-BPSK', not plain 'BPSK'.

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
        otherwise
            error('ocudu_matlab:ocuduGetModulation', ...
                'The supported modulation orders are (1, 2, 4, 6, 8), provided %d', Qm);
    end

end
