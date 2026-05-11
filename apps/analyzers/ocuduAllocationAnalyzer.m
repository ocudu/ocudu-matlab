%ocuduAllocationAnalyzer Draws the allocated PHY channels in a slot.
%   grants = ocuduAllocationAnalyzer draws a resource-grid allocation map from the
%   OCUDU logs corresponding to one slot. It also returns a structure array with
%   a summary of the processed grants:
%   Channel   - the allocated PHY channel (PUSCH, PUCCH, PRACH or SRS)
%   Format    - the PUCCH format (empty otherwise)
%   PRB1      - the allocated PRB set
%   PRB2      - the allocated PRB set after hopping, if applicable (empty otherwise)
%   Symbols   - the allocated OFDM symbols
%   ICS       - the initial cyclic shift (only for PUCCH F0 and F1)
%   OCCI      - the orthogonal cover code index (only for PUCCH F1 and F4).
%   OCCLength - the OCC length / spreading factor (only for PUCCH F4).
%
%   The function asks the user to copy the relevant section of the logs into
%   the system clipboard. Log level can be either INFO or DEBUG. The logs may
%   span multiple slots; only the log entries with the same slot index as the
%   first entry will be part of the analysis.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function grants = ocuduAllocationAnalyzer

    fprintf(['\nCopy the relevant section of the logs to the system clipboard ', ...
        '(typically select and Ctrl+C), then switch back to MATLAB and press any key.\n']);

    pause;

    logs = clipboard('paste');

    fprintf('Parsing the following log section:\n\n%s\n\n', logs);

    isOK = input('Do you want to continue? [Y]/N ', 's');
    if isempty(isOK)
        isOK = 'Y';
    end
    if ~ismember(isOK, {'y', 'Y'})
        fprintf('Parsing aborted.\n');
        return;
    end

    % The grid size must be provided manually.
    gridSize = input('Grid size as a number of RBs: ');

    % Split the logs into lines.
    allLines = splitlines(logs);

    % Remove debug and empty lines, as well as lines from the IQ recorder, if present.
    allLines(startsWith(allLines, '  ')) = [];
    allLines(contains(allLines, ("RX_SYMBOL:" | "RX_PRACH:"))) = [];
    allLines(cellfun(@isempty, allLines)) = [];

    % Check that all logs refer to the same slot.
    slotPattern = "[" + whitespacePattern + digitsPattern(1, 4) + "." + digitsPattern(1, 2) + ']';
    slot = extract(allLines{1}, slotPattern);
    assert(isscalar(slot));
    slot = slot{1};

    foreignLines = ~contains(allLines, slot);
    if any(foreignLines)
        warning('ocudu_matlab:ocuduAllocationAnalyzer', ...
            'Discarding %d line(s) not belonging to slot %s.', sum(foreignLines), slot);
        allLines(foreignLines) = [];
    end

    % Extract allocation details from the provided logs.
    grants = extractData(allLines);

    % If PRACH is present, ask for its config and compute the resource allocation.
    if any(strcmp([grants.Channel], "PRACH"))
        slotNumber = str2double(extractBetween(slot, '.', ']'));
        [prachPRB1, prachSymbols] = parsePRACH(gridSize, slotNumber);
        grants(strcmp([grants.Channel], "PRACH")).PRB1 = prachPRB1;
        grants(strcmp([grants.Channel], "PRACH")).Symbols = prachSymbols;
    end

    % Prepare the resource grid map.
    nSymbols = 14;
    resourceGrid = zeros(gridSize, nSymbols);

    pucchValues = [1; 2; 3; 4; 5];
    puschValue = max(pucchValues) + 1;
    prachValue = puschValue + 1;
    srsValue = prachValue + 1;
    conflictValue = srsValue + 1;
    for g = grants'
        switch g.Channel
            case 'PUSCH'
                value = puschValue;
            case 'PUCCH'
                value = pucchValues(g.Format + 1);
            case 'PRACH'
                value = prachValue;
            case 'SRS'
                value = srsValue;
        end

        % Render the current grant.
        rgTmp = zeros(size(resourceGrid));
        if isempty(g.PRB2)
            rgTmp(g.PRB1, g.Symbols) = value;
        else
            nHopSymbols = numel(g.Symbols);
            hop1end = floor(nHopSymbols/2);

            rgTmp(g.PRB1, g.Symbols(1:hop1end)) = value;
            rgTmp(g.PRB2, g.Symbols(hop1end+1:end)) = value;
        end

        % Check whether the current grant conflicts with previous ones.
        mask = (resourceGrid > 0) & (rgTmp > 0);

        % After adding rgTmp, conflicted cells will read exactly conflictValue.
        resourceGrid(mask) = conflictValue - value;
        resourceGrid = resourceGrid + rgTmp;
    end

    imagesc([0.5, 13.5], [0.5, gridSize-0.5], resourceGrid, [0, conflictValue]);
    set(gca, 'YDir','normal');
    axis([0 14 0 gridSize]);
    xticks(0:2:14);
    title(['Allocation map slot ', slot]);
    xlabel('OFDM symbol index');
    ylabel('Resource block');
    grid on;

    jj = jet(256);
    colormap(jj(round(linspace(1, 256, conflictValue+1)), :));

    % Customize the colorbar ticks and labels.
    c = colorbar;
    c.Ticks = ((0:conflictValue) + 0.5) * conflictValue / (conflictValue + 1);
    c.TickLabels = ["Empty"; "PUCCH F0"; "PUCCH F1"; "PUCCH F2"; "PUCCH F3"; "PUCCH F4"; "PUSCH"; "PRACH"; "SRS"; "CONFLICT"];
end

% Extracts the relevant grant information from the logs.
function grants = extractData(allLines)
    nLines = numel(allLines);
    grants(nLines, 1) = struct(...
        'Channel', [], ...
        'Format', [], ...
        'PRB1', [], ...
        'PRB2', [], ...
        'Symbols', [], ...
        'ICS', [], ...
        'OCCI', [], ...
        'OCCLength', []);

    channelPattern = ("PUCCH" | "PUSCH" | "PRACH" | "SRS") + ":";
    usedLines = 0;
    for iLine = 1:nLines
        line = string(allLines{iLine});
        channel = extract(line, channelPattern);
        assert(isscalar(channel));
        switch channel
        case "PUCCH:"
            pucchGrant = parsePUCCH(line);
            % Only use the PUCCH grant if it's not a PUCCH F1/F4 that multiplexes with a previous grant.
            isNew = ~ismember(pucchGrant.Format, [1, 4]) || ~isMultiplexed(pucchGrant, grants(1:usedLines));
            if isNew
                usedLines = usedLines + 1;
                grants(usedLines) = pucchGrant;
            end
        case "PUSCH:"
            usedLines = usedLines + 1;
            grants(usedLines).Channel = "PUSCH";
            grants = processPUSCH(grants, line, usedLines);
        case "PRACH:"
            usedLines = usedLines + 1;
            grants(usedLines).Channel = "PRACH";
        case "SRS:"
            usedLines = usedLines + 1;
            grants(usedLines).Channel = "SRS";
            grants = processSRS(grants, line, usedLines);
        otherwise
            error('Shouldn''t be here');
        end
    end

    grants = grants(1:usedLines);
end

% Extract the relevant information from a PUSCH log line.
function grants = processPUSCH(grants, line, iLine)
    prbsString = extractBetween(line, 'prb=[', ')');
    prbs = sscanf(prbsString, '%d, %d');
    grants(iLine).PRB1 = (prbs(1) + 1):prbs(2);

    grants(iLine).Symbols = parseSymbolRange(line);
end

% Extract the relevant information from a PUCCH log line.
function pucchGrant = parsePUCCH(line)
    format = double(extractBetween(line, 'format=', ' '));

    pucchGrant = struct(...
        'Channel', "PUCCH", ...
        'Format', format, ...
        'PRB1', [], ...
        'PRB2', [], ...
        'Symbols', [], ...
        'ICS', [], ...
        'OCCI', [], ...
        'OCCLength', []);

    if ((format == 0) || (format == 1))
        prb = double(extractBetween(line, 'prb1=', ' '));
        pucchGrant.PRB1 = prb + 1;

        prbString = extractBetween(line, 'prb2=', ' ');
        if ~contains(prbString, 'na')
            pucchGrant.PRB2 = double(prbString) + 1;
        end

        pucchGrant.ICS = double(extractBetween(line, 'cs=', ' '));
        if (format == 1)
            pucchGrant.OCCI = double(extractBetween(line, 'occ=', ' '));
        end
    elseif ((format == 2) || (format == 3) || (format == 4))
        prbsString = extractBetween(line, 'prb=[', ')');
        prbs = sscanf(prbsString, '%d, %d');
        pucchGrant.PRB1 = (prbs(1) + 1):prbs(2);

        prbsString = extractBetween(line, 'prb2=', 'symb=');
        if ~contains(prbsString, 'na')
            prbs = sscanf(prbsString, '[%d, %d)');
            pucchGrant.PRB2 = (prbs(1) + 1):prbs(2);
        end

        if (format == 4)
            pucchGrant.OCCI      = double(extractBetween(line, 'occ=', ' '));
            pucchGrant.OCCLength = double(extractBetween(line, 'occ_len=', ' '));
        end
    else
        warning('ocudu_matlab:ocuduAllocationAnalyzer', 'Unknown PUCCH Format %d.', format);
    end

    pucchGrant.Symbols = parseSymbolRange(line);
end

% Checks whether pucchGrant is part of a multiplexed resource.
function flag = isMultiplexed(pucchGrant, grants)

    % From all grants, only check those that correspond to a PUCCH channel with the
    % same format as pucchGrant.
    mask = strcmp([grants.Channel], "PUCCH") & ([grants.Format] == pucchGrant.Format);

    flag = false;
    for u = grants(mask)'
        sameLocation = isequal(pucchGrant.Symbols, u.Symbols) ...
            && isequal(pucchGrant.PRB1, u.PRB1) ...
            && isequal(pucchGrant.PRB2, u.PRB2);
        if ~sameLocation
            continue;
        end
        if (pucchGrant.Format == 1)
            % F1: multiplexed if (ICS, OCCI) pair differs.
            flag = (pucchGrant.ICS ~= u.ICS) || (pucchGrant.OCCI ~= u.OCCI);
        elseif (pucchGrant.Format == 4)
            % F4: multiplexed if same OCCLength but different OCCI.
            flag = (pucchGrant.OCCLength == u.OCCLength) && (pucchGrant.OCCI ~= u.OCCI);
        else
            error('ocudu_matlab:ocuduAllocationAnalyzer', 'Unexpected multiplexed PUCCH format %d.', pucchGrant.Format);
        end
        if flag
            break;
        end
    end
end

% Extract the relevant information from an SRS log line.
function grants = processSRS(grants, line, iLine)
    prbsString = extractBetween(line, 'crb=[', ')');
    prbs = sscanf(prbsString, '%d..%d');
    grants(iLine).PRB1 = (prbs(1) + 1):prbs(2);

    grants(iLine).Symbols = parseSymbolRange(line);
end

function symbols = parseSymbolRange(line)
    symbString = extractBetween(line, 'symb=[', ')');
    vals = sscanf(symbString, '%d, %d');
    symbols = (vals(1) + 1):vals(2);
end

% Ask the user for the PRACH config and compute its resource grid allocation.
function [prb1, symbols] = parsePRACH(gridSize, slotNumber)
    carrierSCS = input('Carrier subcarrier spacing [kHz]: ');
    if (carrierSCS == 15)
        defaultDuplex = 'FDD';
        duplexString = '[FDD]/TDD';
    elseif ((carrierSCS == 30) || (carrierSCS == 120))
        defaultDuplex = 'TDD';
        duplexString = 'FDD/[TDD]';
    else
        error('ocudu_matlab:ocuduAllocationAnalyzer', 'Unsupported subcarrier spacing %d kHz', carrierSCS);
    end
    duplexMode = input(['Duplex mode: ', duplexString, ' '], 's');
    if isempty(duplexMode)
        duplexMode = defaultDuplex;
    end
    assert(ismember(duplexMode, {'FDD', 'fdd', 'TDD', 'tdd'}), ...
        'ocudu_matlab:ocuduAllocationAnalyzer', 'Unsupported subcarrier spacing %d kHz', carrierSCS);

    fprintf(['\nCopy the prach: section of your gNB config to the system clipboard, ', ...
        'then switch back to MATLAB and press any key.\n']);
    pause;
    prachYaml = string(clipboard('paste')) + newline;

    fprintf('Parsing the following yaml section:\n\n%s\n\n', prachYaml);

    isOK = input('Do you want to continue? [Y]/N ', 's');
    if isempty(isOK)
        isOK = 'Y';
    end
    if ~ismember(isOK, {'y', 'Y'})
        error('Parsing aborted.\n');
    end

    configIndexString = extractBetween(prachYaml, 'prach_config_index: ', newline);
    configIndex = double(configIndexString);
    freqStartString = extractBetween(prachYaml, 'prach_frequency_start: ', newline);
    if isempty(freqStartString)
        freqStart = input('PRACH frequency start (e.g., see msg1-FrequencyStart in SIB1) as a number of RBs: ');
    else
        freqStart = double(freqStartString);
    end

    carrier = nrCarrierConfig;
    carrier.SubcarrierSpacing = carrierSCS;
    carrier.NSizeGrid = gridSize;

    if ((carrierSCS == 15) || (carrierSCS == 30))
        freqRange = 'FR1';
    elseif (carrierSCS == 120)
        freqRange = 'FR2';
    else
        error('ocudu_matlab:ocuduAllocationAnalyzer', ...
            'Subcarrier spacing %d kHz not supported.', carrierSCS);
    end

    % Look up the preamble format so that ocuduConfigurePRACH can correctly set
    % SubcarrierSpacing, LRA, and other format-dependent properties that nrPRACHConfig
    % does not update automatically when ConfigurationIndex is assigned.
    if strcmp(freqRange, 'FR2')
        cfgTable = nrPRACHConfig.Tables.ConfigurationsFR2;
    elseif strcmp(duplexMode, 'FDD')
        cfgTable = nrPRACHConfig.Tables.ConfigurationsFR1PairedSUL;
    else
        cfgTable = nrPRACHConfig.Tables.ConfigurationsFR1Unpaired;
    end
    preambleFormat = cfgTable.PreambleFormat{cfgTable.ConfigurationIndex == configIndex};

    prach = ocuduLib.phy.helpers.ocuduConfigurePRACH(preambleFormat, ...
        DuplexMode=duplexMode, SubcarrierSpacing=carrierSCS, FrequencyStart=freqStart);
    % ocuduConfigurePRACH picks the first matching ConfigurationIndex; override with
    % the specific index from the YAML to get the correct timing pattern.
    prach.ConfigurationIndex = configIndex;

    if ~strcmp(prach.Format, 'B4')
        warning('ocudu_matlab:ocuduAllocationAnalyzer', ...
            'PRACH allocation has only been tested with format B4 (detected format: %s).', prach.Format);
    end

    prach.NPRACHSlot = slotNumber;
    [~, info] = nrPRACHIndices(carrier, prach);
    prb1 = info.PRBSet + 1;

    % Long PRACH (formats 0–3) don't map cleanly to slot OFDM symbols.
    if ismember(prach.Format, {'0', '1', '2', '3'})
        warning('ocudu_matlab:ocuduAllocationAnalyzer', ...
            'Long PRACH format %s: showing all 14 symbols as approximation.', prach.Format);
        symbols = 1:14;
    else
        startSymbol = mod(prach.SymbolLocation, 14);
        symbols = (startSymbol + 1) : (startSymbol + prach.PRACHDuration);
    end
end
