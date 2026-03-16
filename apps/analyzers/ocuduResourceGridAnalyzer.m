%ocuduResourceGridAnalyzer Plots the heat map of a resource grid.
%   ocuduResourceGridAnalyzer(NRBS, RGFILENAME, RGOFFSET, RGSIZE) displays the
%   content (amplitude) of a resource grid of NRBS resource blocks (frequency
%   domain) and one slot (time domain). RGOFFSET and RGSIZE are the offset
%   and size, as a number of single-precision complex floating point numbers,
%   of the slot to be analyzed inside the binary file.
%
%   RG = ocuduResourceGridAnalyzer(...) also returns a matrix RG with the complex-
%   valued samples of the resource grid (rows are subcarriers, columns are symbols).

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

function RG = ocuduResourceGridAnalyzer(nRBs, rgFilename, rgOffset, rgSize)
    arguments
        nRBs (1, 1) double {mustBeInteger, mustBePositive}
        rgFilename char {mustBeFile}
        rgOffset (1, 1) double {mustBeInteger, mustBeNonnegative}
        rgSize (1, 1) double {mustBeInteger, mustBePositive}
    end

    nSubcarriers = nRBs * 12;
    nSymbols = 14;
    nPorts = floor(rgSize / (nSubcarriers * nSymbols));

    assert(nSubcarriers * nSymbols * nPorts == rgSize, ['The dimensions of the resource grid ', ...
        '(%d x %d) are not consistent with the buffer size %d.'], nSubcarriers, nSymbols, rgSize);

    % Read file containing the resource grid.
    rxGrid = reshape(ocuduTest.helpers.readComplexFloatFile(rgFilename, rgOffset, rgSize), ...
        [nSubcarriers, nSymbols, nPorts]);

    % Plot the heat map of the RG amplitude.
    figure("Name", "ocuduResourceGridAnalyzer");
    tiledlayout('flow');

    for iPort = 1:nPorts
        nexttile
        imagesc(0, 0, abs(rxGrid(:,:,iPort)));
        % By default, imagesc reverses the y axis.
        set(gca, 'YDir','normal');
        colorbar;
        xlabel('Symbol')
        ylabel('Subcarrier')
    end

    if nargout == 1
        RG = rxGrid;
    end
