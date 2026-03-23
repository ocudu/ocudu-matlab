%ocuduAllocationAnalyzer Draws the allocated PHY channels in a slot.
%   grants = ocuduAllocationAnalyzer draws a resource-grid allocation map from the
%   OCUDU logs corresponding to one slot. It also returns a structure array with
%   a summary of the processed grants:
%   Channel   - the allocated PHY channel (PUSCH or PUCCH)
%   Format    - the PUCCH format (empty otherwise)
%   PRB1      - the allocated PRB set
%   PRB2      - the allocated PRB set after hopping, if applicable (empty otherwise)
%   Symbols   - the allocated OFDM symbols
%   ICS       - the initial cyclic shift (only for PUCCH F1)
%   OCCI      - the orthogonal cover code index (only for PUCCH F1).
%
%   The function asks the user to copy the relevant section of the logs into
%   the system clipboard. Log level can be either INFO or DEBUG.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

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

    % Remove debug and empty lines, if present.
    allLines(startsWith(allLines, '  ')) = [];
    allLines(cellfun(@isempty, allLines)) = [];

    % Check that all logs refer to the same slot.
    slotPattern = "[" + whitespacePattern + digitsPattern(1, 4) + "." + digitsPattern(1, 2) + ']';
    slot = extract(allLines{1}, slotPattern);
    assert(isscalar(slot));
    slot = slot{1};

    assert(all(contains(allLines, slot)), 'ocudu_matlab:ocuduAllocationAnalyzer', 'The provided logs span more than one slot');

    % Extract allocation details from the provided logs.
    grants = extractData(allLines);

    % Prepare the resource grid map.
    nSymbols = 14;
    resourceGrid = zeros(gridSize, nSymbols);

    pucchValues = [0; 1; 2];
    puschValue = 3;
    conflictValue = 4;
    for g = grants'
        switch g.Channel
            case 'PUSCH'
                value = puschValue;
            case 'PUCCH'
                value = pucchValues(g.Format + 1);
        end

        % Render the current grant.
        rgTmp = zeros(size(resourceGrid));
        if isempty(g.PRB2)
            rgTmp(g.PRB1, g.Symbols) = value;
        else
            nSymbols = numel(g.Symbols);
            hop1end = floor(nSymbols/2);

            rgTmp(g.PRB1, g.Symbols(1:hop1end)) = value;
            rgTmp(g.PRB2, g.Symbols(hop1end+1:end)) = value;
        end

        % Check whether the current grant conflicts with previous ones.
        mask = (resourceGrid > 0) & (rgTmp > 0);

        % Mark conflicting RBs.
        resourceGrid(mask) = conflictValue - value;

        % Mark grant.
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

    % Fine-tuned color map.
    maxColor = conflictValue;
    jj = jet(256);
    colormap(jj(round(linspace(1, 256, maxColor+1)), :));

    % Customize the colorbar ticks and labels.
    c = colorbar;
    c.Ticks = ((0:maxColor) + 0.5) * maxColor / (maxColor + 1);
    c.TickLabels = ["Empty"; "PUCCH F1"; "PUCCH F2"; "PUSCH"; "CONFLICT"];
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
        'OCCI', []);

    channelPattern = ("PUCCH" | "PUSCH" | "PRACH") + ":";
    usedLines = 0;
    for iLine = 1:nLines
        line = string(allLines{iLine});
        channel = extract(line, channelPattern);
        assert(isscalar(channel));
        switch channel
        case "PUCCH:"
            pucchGrant = parsePUCCH(line);
            % Only use the PUCCH grant if it's not a PUCCH F1 that doesn't multiplex with a previous grant.
            isNew = (pucchGrant.Format ~= 1) || ~isMultiplexed(pucchGrant, grants(1:usedLines));
            if isNew
                usedLines = usedLines + 1;
                grants(usedLines) = pucchGrant;
            end
        case "PUSCH:"
            usedLines = usedLines + 1;
            grants(usedLines).Channel = "PUSCH";
            grants = processPUSCH(grants, line, usedLines);
        case "PRACH:"
            % todo
            warning('ocudu_matlab:ocuduAllocationAnalyzer', 'PRACH not supported yet.');
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

    symbString = extractBetween(line, 'symb=[', ')');
    symbols = sscanf(symbString, '%d, %d');
    grants(iLine).Symbols = (symbols(1) + 1):symbols(2);
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
        'OCCI', []);

    if (format == 1)
        prb = double(extractBetween(line, 'prb1=', ' '));
        pucchGrant.PRB1 = prb + 1;

        prbString = extractBetween(line, 'prb2=', ' ');
        if ~contains(prbString, 'na')
            pucchGrant.PRB2 = double(prbString) + 1;
        end

        pucchGrant.ICS = double(extractBetween(line, 'cs=', ' '));
        pucchGrant.OCCI = double(extractBetween(line, 'occ=', ' '));
    elseif (format == 2)
        prbsString = extractBetween(line, 'prb=[', ')');
        prbs = sscanf(prbsString, '%d, %d');
        pucchGrant.PRB1 = (prbs(1) + 1):prbs(2);

        prbsString = extractBetween(line, 'prb2=', 'symb=');
        if ~contains(prbsString, 'na')
            prbs = sscanf(prbsString, '[%d, %d)');
            pucchGrant.PRB2 = (prbs(1) + 1):prbs(2);
        end
    else
        warning('ocudu_matlab:ocuduAllocationAnalyzer', 'PUCCH Format %d not supported yet.', format);
    end

    symbString = extractBetween(line, 'symb=[', ')');
    symbols = sscanf(symbString, '%d, %d');

    pucchGrant.Symbols = (symbols(1) + 1):symbols(2);
end

% Checks whether pucchGrant is part of a multiplexed resource.
function flag = isMultiplexed(pucchGrant, grants)

    % Only PUCCH Format 1 can be multiplexed.
    mask = strcmp([grants.Channel], "PUCCH");
    mask = mask & ([grants.Format] == 1);

    flag = false;
    for u = grants(mask)'
        % Multiplexed if same symbols...
        flag = isequal(pucchGrant.Symbols, u.Symbols);
        % and same PRBs ...
        flag = flag && isequal(pucchGrant.PRB1, u.PRB1);
        flag = flag && isequal(pucchGrant.PRB2, u.PRB2);
        % but different (ICS, OCCI) pair.
        flag = flag && ((pucchGrant.ICS ~= u.ICS) || (pucchGrant.OCCI ~= u.OCCI));
        if flag
            break;
        end
    end
end
