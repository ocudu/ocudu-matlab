%ocuduPUCCH1 Physical uplink control channel Format 1 modulator.
%   [SYMBOLS, INDICES] = ocuduPUCCH1(CARRIER, PUCCH, ACK, SR)
%   modulates a PUCCH Format 1 message containing the HARQ acknowledgment bits
%   provided by ACK and the scheduling request provided by SR. It returns the
%   complex symbols SYMBOLS as well as a column vector of RE indices INDICES.
%
%   See also nrPUCCH1 and nrPUCCHIndices.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [symbols, indices] = ocuduPUCCH1(carrier, pucch, ack, sr)

    FrequencyHopping = 'disabled';
    if strcmp(pucch.FrequencyHopping, 'intraSlot')
        FrequencyHopping = 'enabled';
    end

    symbols = nrPUCCH1(ack, sr, pucch.SymbolAllocation, ...
        carrier.CyclicPrefix, carrier.NSlot, carrier.NCellID, ...
        pucch.GroupHopping, pucch.InitialCyclicShift, FrequencyHopping, ...
        pucch.OCCI);
    indices = nrPUCCHIndices(carrier, pucch, 'IndexStyle', 'subscript', 'IndexBase', '0based');
end
