%ocuduGetBitsSymbol Returns the number of bits per modulation symbol.
%   NBITS = ocuduGetBitsSymbol(MODULATION) returns the number of bits per symbol
%   for the given MODULATION scheme. MODULATION is a character array identifying
%   a modulation scheme according to either MATLAB convention (i.e., 'BPSK',
%   'pi/2-BPSK', 'QPSK', '16QAM', '64QAM' or '256QAM') or OCUDU convention (i.e.,
%   'BPSK','PI_2_BPSK', 'QPSK', 'QAM16', 'QAM64' or 'QAM256').

%
%   Copyright 2021-2025 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

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
        otherwise
            error('ocudu_matlab:ocuduGetBitsSymbol', 'Unknown modulation %s.', modulation);
    end
end
