%ocuduExpandMCS Returns the target code rate for a given configuration.
%   [TARGETCODERATE, QM] = ocuduExpandMCS(MCSTABLE, MCS) returns the target code
%   rate TARGETCODERATE and modulation order QM (according to the 3GPP convention:
%   i.e., the number of bits per symbol) given a specific modulation and coding
%   scheme index MCS (0-28) and associated table MCSTABLE ('qam64', 'qam256',
%   'qam64LowSE'), as defined in TS 38.214 Section 5.1.3.1.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [targetCodeRate, Qm] = ocuduExpandMCS(mcs, mcsTable)
    allTables = nrPDSCHMCSTables;

    indexMCS = mcs + 1;
    if strcmp(mcsTable, 'qam64')
        requestedTable = allTables.QAM64Table;
    elseif strcmp(mcsTable, 'qam256')
        requestedTable = allTables.QAM256Table;
    elseif strcmp(mcsTable, 'qam64LowSE')
        requestedTable = allTables.QAM64LowSETable;
    else
        error('ocudu_matlab:ocuduExpandMCS', 'Unsupported MCS table %s', mcsTable);
    end

    targetCodeRate = round(requestedTable(indexMCS, :).TargetCodeRate * 1024);
    Qm = requestedTable(indexMCS, :).Qm;
end
