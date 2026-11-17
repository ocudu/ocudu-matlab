%ocuduParsePUSCHLog Parses all PUSCH entries of an OCUDU gNB log file.
%   T = ocuduParsePUSCHLog(LOGFILE) reads the OCUDU gNB log file LOGFILE and returns
%   a table T with one row per PUSCH log entry. The gNB PHY log level must be set to
%   "debug" (a warning is issued if no PUSCH entry is found). The table has the
%   following variables:
%
%   Time            - Log timestamp (datetime).
%   Slot            - Slot label as written in the log, "SFN.slot" (string).
%   SFN, SlotIndex  - System frame number and slot index within the frame.
%   RNTI            - UE RNTI (NaN if not logged).
%   HARQId, RV      - HARQ process ID and redundancy version.
%   NewData         - True if the transmission carries new data.
%   PRBStart, NPRB  - First PRB and number of PRBs.
%   SymStart, NSym  - First OFDM symbol and number of OFDM symbols.
%   Modulation      - Modulation scheme (string).
%   TCR             - Target code rate.
%   TBS             - Transport block size in bytes.
%   NumLayers       - Number of transmission layers.
%   OACK, OCSI1     - Number of multiplexed HARQ-ACK and CSI Part 1 bits.
%   CRCOK           - True if the transport block CRC passed.
%   Iter            - Average number of LDPC iterations.
%   SINRChEst       - SINR estimated by the channel estimator, in dB.
%   SINREq          - SINR at the equalizer output, in dB.
%   SINREVM         - SINR derived from the EVM, in dB.
%   SINR            - SINR reported to the MAC, i.e., the one selected among the
%                     three above (marked with [sel] in the log), in dB.
%   EVM             - 1-by-14 EVM per OFDM symbol (NaN for DM-RS symbols).
%   EPRE            - Energy per resource element, in dB.
%   RSRP            - 1-by-P RSRP per receive port, in dB.
%   TAlign          - Time alignment (residual timing offset), in ns.
%   CFO             - Carrier frequency offset, in Hz.
%   DCPosition      - DC subcarrier index (NaN if not logged).
%   RGOffset        - Offset, as a number of complex single-precision samples, of
%                     the resource grid dump of the slot inside the RX symbols file
%                     (NaN if the slot was not dumped).
%   RGSize          - Size of the resource grid dump (NaN if not dumped).
%   Entry           - The full log entry text, to be parsed by ocuduParseLogs.
%
%   Resource grid dumps (RX_SYMBOL lines) are associated with all the PUSCH entries
%   with the same slot label whose timestamp is within MatchWindow seconds of the
%   dump timestamp. Different PUSCH transmissions in the same slot share the dump.
%
%   T = ocuduParsePUSCHLog(LOGFILE, MatchWindow=W) sets the matching window to W
%   seconds (default 0.1, well below the 10.24-second SFN wrap-around period).
%
%   Example:
%   T = ocuduParsePUSCHLog('gnb.log');
%   iRow = find(~T.CRCOK & ~isnan(T.RGOffset), 1);
%   [carrier, pusch, extra] = ocuduParseLogs(Entry=T.Entry{iRow}, SubcarrierSpacing=30, NSizeGrid=273);
%   ocuduPUSCHAnalyzer(carrier, pusch, extra, 'samples.iq', T.RGOffset(iRow), T.RGSize(iRow));
%
%   See also ocuduParseLogs, ocuduPUSCHAnalyzer.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function T = ocuduParsePUSCHLog(logFile, options)
    arguments
        logFile             {mustBeTextScalar, mustBeFile}
        options.MatchWindow (1, 1) double {mustBePositive} = 0.1
    end

    logText = fileread(logFile);

    % Extract PUSCH entries: header line followed by the indented parameter lines.
    % The PHY logger tag is "[PHY     ]" in recent gNB versions, "[UL-PHY1 ]" in older ones.
    headerPattern = '^(\S+) \[[\w-]*PHY\w*\s*\] \[D\] \[\s*(\d+)\.(\d+)\] PUSCH: ([^\n]*)';
    [blocks, tokens] = regexp(logText, [headerPattern, '(?:\n  [^\n]*)*'], ...
        'match', 'tokens', 'lineanchors');
    blocks = blocks(:);
    nEntries = numel(blocks);
    tokens = vertcat(tokens{:});
    if isempty(tokens)
        tokens = cell(0, 4);
        warning('ocudu:ocuduParsePUSCHLog:noEntries', ...
            'No PUSCH entries found in %s: is the gNB PHY log level set to "debug"?', logFile);
    end

    T = table;
    T.Time = parseTime(tokens(:, 1));
    T.Slot = string(tokens(:, 2)) + "." + string(tokens(:, 3));
    T.SFN = str2double(tokens(:, 2));
    T.SlotIndex = str2double(tokens(:, 3));
    headers = tokens(:, 4);

    rnti = getField(blocks, '\n  rnti=0x([0-9a-fA-F]+)', "");
    isLogged = ~cellfun(@isempty, rnti);
    T.RNTI = nan(nEntries, 1);
    T.RNTI(isLogged) = hex2dec(rnti(isLogged));
    % The HARQ process ID is logged as "harq_id" in recent gNB versions, "h_id" in older ones.
    T.HARQId = getNumber(blocks, '\n  (?:harq_id|h_id)=(\d+)');
    T.RV = getNumber(blocks, '\n  rv=(\d+)');
    T.NewData = strcmp(getField(blocks, '\n  new_data=(\w+)', ""), 'true');

    prb = getPair(blocks, '\n  prb=\[(\d+), (\d+)\)');
    T.PRBStart = prb(:, 1);
    T.NPRB = prb(:, 2) - prb(:, 1);
    symb = getPair(blocks, '\n  symb=\[(\d+), (\d+)\)');
    T.SymStart = symb(:, 1);
    T.NSym = symb(:, 2) - symb(:, 1);

    T.Modulation = string(getField(blocks, '\n  mod=(\S+)', ""));
    T.TCR = getNumber(blocks, '\n  tcr=([\d.]+)');
    T.TBS = getNumber(headers, 'tbs=(\d+)');
    T.NumLayers = getNumber(blocks, '\n  nof_layers=(\d+)');
    T.OACK = getNumber(blocks, '\n  oack=(\d+)');
    T.OCSI1 = getNumber(blocks, '\n  ocsi1=(\d+)');

    T.CRCOK = contains(headers, 'crc=OK');
    T.Iter = getNumber(blocks, '\n  iter=([\d.]+)');
    % Real numbers, possibly infinite (the gNB logs "inf" and "-inf").
    num = '([-+]?(?:inf|[\d.]+))';
    % The gNB appends [sel] to the label of the SINR type reported to the MAC.
    T.SINRChEst = getNumber(blocks, ['\n  sinr_ch_est(?:\[sel\])?=', num, 'dB']);
    T.SINREq = getNumber(blocks, ['\n  sinr_eq(?:\[sel\])?=', num, 'dB']);
    T.SINREVM = getNumber(blocks, ['\n  sinr_evm(?:\[sel\])?=', num, 'dB']);
    T.SINR = getNumber(blocks, ['\n  sinr=', num, 'dB']);
    T.EVM = getList(blocks, '\n  evm=\[([^\]]*)\]', 14);
    T.EPRE = getNumber(blocks, ['\n  epre=', num, 'dB']);
    T.RSRP = getList(blocks, '\n  rsrp=\[([^\]]*)\]dB', []);
    T.TAlign = getNumber(blocks, ['\n  t_align=', num, 'us']) * 1000;
    T.CFO = getNumber(blocks, ['\n  cfo=', num, 'Hz']);
    T.DCPosition = getNumber(blocks, '\n  dc_position=(\d+)');

    % Associate resource grid dumps with the PUSCH entries.
    T.RGOffset = nan(nEntries, 1);
    T.RGSize = nan(nEntries, 1);

    dumpTokens = regexp(logText, ...
        '^(\S+) \[[\w-]*PHY\w*\s*\] \[I\] \[\s*(\d+)\.(\d+)\] RX_SYMBOL: sector=\d+ offset=(\d+) size=(\d+)', ...
        'tokens', 'lineanchors');
    dumpTokens = vertcat(dumpTokens{:});

    if ~isempty(dumpTokens)
        dumpTime = parseTime(dumpTokens(:, 1));
        dumpSlot = string(dumpTokens(:, 2)) + "." + string(dumpTokens(:, 3));
        dumpOffset = str2double(dumpTokens(:, 4));
        dumpSize = str2double(dumpTokens(:, 5));

        % Group PUSCH rows by slot label.
        [slotLabels, ~, slotGroup] = unique(T.Slot);
        rowsBySlot = accumarray(slotGroup, (1:nEntries)', [numel(slotLabels), 1], @(x) {x});
        [isKnown, dumpGroup] = ismember(dumpSlot, slotLabels);

        % Distance (in seconds) between each PUSCH row and its associated dump.
        bestDistance = inf(nEntries, 1);
        for iDump = find(isKnown)'
            rows = rowsBySlot{dumpGroup(iDump)};
            distance = abs(seconds(T.Time(rows) - dumpTime(iDump)));
            isMatch = (distance <= options.MatchWindow) & (distance < bestDistance(rows));
            rows = rows(isMatch);
            bestDistance(rows) = distance(isMatch);
            T.RGOffset(rows) = dumpOffset(iDump);
            T.RGSize(rows) = dumpSize(iDump);
        end
    end

    T.Entry = blocks;
end % of function ocuduParsePUSCHLog(logFile, options)

function t = parseTime(timeStrings)
% Converts the log timestamps into a column of datetime values.
    t = datetime(timeStrings, InputFormat='yyyy-MM-dd''T''HH:mm:ss.SSSSSS', ...
        Format='yyyy-MM-dd HH:mm:ss.SSSSSS');
    t = t(:);
end % of function parseTime(timeStrings)

function values = getField(blocks, pattern, default)
% Returns the first token captured by PATTERN in each block, DEFAULT if no match.
    values = regexp(blocks, pattern, 'tokens', 'once');
    isMissing = cellfun(@isempty, values);
    values(~isMissing) = cellfun(@(c) c{1}, values(~isMissing), 'UniformOutput', false);
    values(isMissing) = {char(default)};
end % of function getField(blocks, pattern, default)

function values = getNumber(blocks, pattern)
% Returns the first token captured by PATTERN in each block as a number, NaN if no match.
    values = str2double(getField(blocks, pattern, "NaN"));
    values = values(:);
end % of function getNumber(blocks, pattern)

function values = getPair(blocks, pattern)
% Returns the two tokens captured by PATTERN in each block as a row of an N-by-2
% matrix, NaN if no match.
    tok = regexp(blocks, pattern, 'tokens', 'once');
    values = nan(numel(blocks), 2);
    isFound = ~cellfun(@isempty, tok);
    values(isFound, :) = str2double(vertcat(tok{isFound}));
end % of function getPair(blocks, pattern)

function values = getList(blocks, pattern, nValues)
% Returns the comma-separated list captured by PATTERN in each block as a row of a
% matrix padded with NaN. Non-numeric entries (e.g., "na") are converted to NaN. If
% NVALUES is empty, the number of columns is the length of the longest list.
    lists = getField(blocks, pattern, "");
    parsed = cellfun(@(s) str2double(strsplit(s, ',')), lists, 'UniformOutput', false);
    parsed(cellfun(@isempty, lists)) = {[]};
    if isempty(nValues)
        nValues = max([cellfun(@numel, parsed); 1]);
    end
    values = nan(numel(blocks), nValues);
    for iBlock = 1:numel(blocks)
        n = min(numel(parsed{iBlock}), nValues);
        values(iBlock, 1:n) = parsed{iBlock}(1:n);
    end
end % of function getList(blocks, pattern, nValues)
