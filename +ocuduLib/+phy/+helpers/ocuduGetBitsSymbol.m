%ocuduGetBitsSymbol Returns the number of bits per modulation symbol.
%   NBITS = ocuduGetBitsSymbol(MODULATION) returns the number of bits per symbol
%   for the given MODULATION scheme. MODULATION is a character array identifying
%   a modulation scheme according to either MATLAB convention (i.e., 'BPSK',
%   'pi/2-BPSK', 'QPSK', '16QAM', '64QAM', '256QAM' or '1024QAM') or OCUDU convention (i.e.,
%   'BPSK','PI_2_BPSK', 'QPSK', 'QAM16', 'QAM64', 'QAM256' or 'QAM1024').

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function nBits = ocuduGetBitsSymbol(modulation)
    switch modulation
        case {'BPSK', 'pi/2-BPSK', 'PI_2_BPSK'}
            nBits = 1;
        case 'QPSK'
            nBits = 2;
        case {'16QAM', 'QAM16'}
            nBits = 4;
        case {'64QAM', 'QAM64'}
            nBits = 6;
        case {'256QAM', 'QAM256'}
            nBits = 8;
        case {'1024QAM', 'QAM1024'}
            nBits = 10;
        otherwise
            error('ocudu_matlab:ocuduGetBitsSymbol', 'Unknown modulation %s.', modulation);
    end
end
