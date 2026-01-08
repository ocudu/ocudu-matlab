%combinePUSCHSims PUSCH simulation summary.
%   combinePUSCHSims(FILES) draws the BLER and throughput curves corresponding
%   to the PUSCHBLER simulation objects saved in FILES.
%   IMPORTANT: combinePUSCHSims does not check whether all the PUSCHBLER objects
%   have the same configuration.
%
%   FILES is an array of strings, e.g. ["my_file1.mat", "my_file2.mat"]. Each
%   file in FILES must contain one and only one *locked* PUSCHBLER object.
%
%   The file names in FILE can be followed by a parameter/value pair specifying
%   the type of throughput plot, either 'absolute' or 'relative' (default 'absolute'), e.g.
%   combinePUSCHSims(FILES, 'TPType', 'relative')
%
%   TABLEOCUDU = combinePUSCHSims(___) returns a table with a summary of the
%   simulations using the OCUDU PUSCH decoder.
%
%   [TABLEOCUDU, TABLEMATLAB] = combinePUSCHSims(___) also returns a summary
%   table for the simulations using the MATLAB PUSCH decoder.
%
%   [TABLEOCUDU, TABLEMATLAB, FIGS] = combinePUSCHSims(___) also returns a 2x1
%   array of the created axes objects.
%
%   Example
%      D = dir('my_file*.mat');
%      FILES = string({D.name});
%      [tableOCUDU, tableMATLAB] = combinePUSCHSims(FILES);
%
%   See also PUSCHBLER.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [tableOCUDU, tableMATLAB, figs] = combinePUSCHSims(files, opt)
    arguments
        files (1,:) string
        opt.TPType (1, :) string {mustBeMember(opt.TPType, {'absolute', 'relative'})} = 'absolute'
    end

    returnMATLAB = false;
    returnOCUDU = false;
    if nargout > 1
        returnMATLAB = true;
    end
    if nargout > 0
        returnOCUDU = true;
    end

    tpFig = axes(figure);
    hold on;
    blerFig = axes(figure);
    set(blerFig, "Yscale", "log");
    hold on;

    numCurves = numel(files);

    if returnOCUDU || returnMATLAB
        varNames = ["PRB", "Symbols", "MCS table", "MCS index", "Modulation", ...
            "Target rate", "Spectral Eff", "TBS", "SNR @ 1e-2"];
        varTypes = ["double", "double", "string", "double", "string", "double", ...
            "double", "double", "double"];
        nVariables = 9;
      if returnOCUDU
        tableOCUDU = table('Size', [numCurves, nVariables], 'VariableTypes', varTypes, ...
            'VariableNames', varNames);
      end
      if returnMATLAB
        tableMATLAB = table('Size', [numCurves, nVariables], 'VariableTypes', varTypes, ...
            'VariableNames', varNames);
      end
    end

    hasOCUDU = false;
    hasMATLAB = false;
    for iFile = 1:numCurves
        filename = files(iFile);
        fprintf('Processing file %s...\n', filename);
        assert(exist(filename, 'file') == 2, 'ocudu_matlab:combinePUSCHSims', 'File not found.');

        S = load(filename);
        puschName = fieldnames(S);
        assert(isscalar(puschName), 'ocudu_matlab:combinePUSCHSims', ...
            'File doesn''t contain a single object.');
        puschsim = S.(puschName{1});
        assert(isa(puschsim, 'PUSCHBLER'), 'ocudu_matlab::combinePUSCHSims', ...
            'File doesn''t contain a PUSCHBLER object');
        assert(puschsim.isLocked, 'ocudu_matlab::combinePUSCHSims', ...
            'Object %s is unlocked', puschName{1});

        SNRrange = puschsim.SNRrange;
        desiredBLER = 1e-2;
        if ~strcmp(puschsim.ImplementationType, 'ocudu')
            hasMATLAB = true;
            blerMATLAB = puschsim.BlockErrorRateMATLAB;

            tp = puschsim.ThroughputMATLAB;
            if strcmp(opt.TPType, 'relative')
                tp = tp / puschsim.MaxThroughput * 100;
            end
            plot(tpFig, SNRrange, tp, '-', 'LineWidth', 1, 'Color', [0 0.4500 0.7400]);
            semilogy(blerFig, puschsim.SNRrange, blerMATLAB, ...
                '-', 'LineWidth', 1, 'Color', [0 0.4500 0.7400]);

            if returnMATLAB
                targetSNR = interpolate(SNRrange, blerMATLAB, desiredBLER);
                tableMATLAB(iFile, :) = createTableEntry(puschsim, targetSNR);
            end
        end
        if ~strcmp(puschsim.ImplementationType, 'matlab')
            hasOCUDU = true;
            blerOCUDU = puschsim.BlockErrorRateOCUDU;

            tp = puschsim.ThroughputOCUDU;
            if strcmp(opt.TPType, 'relative')
                tp = tp / puschsim.MaxThroughput * 100;
            end
            plot(tpFig, SNRrange, tp, '-', 'LineWidth', 1, 'Color', [0.8500 0.3250 0.0980]);
            semilogy(blerFig, puschsim.SNRrange, blerOCUDU, ...
                '-', 'LineWidth', 1, 'Color', [0.8500 0.3250 0.0980]);
            if returnOCUDU
                targetSNR = interpolate(SNRrange, blerOCUDU, desiredBLER);
                tableOCUDU(iFile, :) = createTableEntry(puschsim, targetSNR);
            end
        end
    end % of for iFile = 1:numCurves

    lineLegend = {};
    if hasMATLAB
        lineLegend{end + 1} = 'MATLAB';
    end
    if hasOCUDU
        lineLegend{end + 1} = 'OCUDU';
    end

    xlabel(tpFig, 'SNR [dB]');
    if strcmp(opt.TPType, 'relative')
        ylabel(tpFig, 'Throughput %');
    else
        ylabel(tpFig, 'Throughput Mbps');
    end
    grid(tpFig, 'ON');
    legend(tpFig, lineLegend);
    xlabel(blerFig, 'SNR [dB]');
    ylabel(blerFig, 'BLER');
    grid(blerFig, 'ON');
    legend(blerFig, lineLegend);

    if nargout == 3
        figs = [tpFig; blerFig];
    end

end % of function [tableOCUDU, tableMATLAB] = combinePUSCHSims(files)

function snr = interpolate(snrRange, blerRange, value)
%Finds the SNR corresponding to a BLER of "value" by interpolating the curve
%   (snrRange vs blerRange).
    index = find(blerRange > value, 1, 'last');
    if isempty(index) || (index == length(blerRange))
        snr = nan;
        return;
    end
    slope = (snrRange(index) - snrRange(index + 1)) / (blerRange(index) - blerRange(index + 1));
    snr = snrRange(index) + (value - blerRange(index+1)) * slope;
end

function t = createTableEntry(puschsim, targetSNR)

    symbolBits = [1 1 2 4 6 8];
    modulations = {'BPSK', 'pi/2-BPSK', 'QPSK', '16QAM', '64QAM', '256QAM'};
    ix = strcmp(puschsim.Modulation, modulations);
    t = {length(puschsim.PRBSet), ... number of PRBs
        puschsim.SymbolAllocation(2), ...                 number of OFDM symbols
        puschsim.MCSTable, ...
        puschsim.MCSIndex, ...
        puschsim.Modulation, ...
        puschsim.TargetCodeRate, ...
        puschsim.TargetCodeRate * symbolBits(ix), ...
        puschsim.TBS, ...
        targetSNR};
end
