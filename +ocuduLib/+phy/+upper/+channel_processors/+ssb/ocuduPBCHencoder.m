%ocuduPBCHEncoder Physical broadcast channel encoding.
%   CW = ocuduPBCHEncoder(PAYLOAD, NCELLID, SSBINDEX, LMAX, SFN, HRF, KSSB)
%   encodes the 24-bit BCH payload PAYLOAD and returns the codeword CW.
%
%   See also nrBCH.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function cw = ocuduPBCHencoder(payload, NCellID, SSBindex, Lmax, SFN, hrf, kSSB)

    % subcarrier offset described in TS 38.211 7.4.3.1
    if Lmax == 64
        idxOffset = SSBindex;
    else
        idxOffset = kSSB;
    end
    cw = nrBCH(payload, SFN, hrf, Lmax, idxOffset, NCellID);

end
