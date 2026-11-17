%ocuduPUSCHReceiver Processes a PUSCH resource grid with the OCUDU receiver chain.
%   [BITS, CRCOK, INFO] = ocuduMEX.phy.ocuduPUSCHReceiver(CARRIER, PUSCH, RXGRID, TCR)
%   runs the OCUDU channel estimator, PUSCH demodulator and UL-SCH decoder (MEX
%   implementations) on the received resource grid RXGRID (subcarriers x symbols x
%   receive ports) for the PUSCH transmission described by the nrCarrierConfig CARRIER
%   and the nrPUSCHConfig PUSCH, with target code rate TCR. It returns the decoded
%   transport block BITS (int8 column vector, as nrULSCHDecoder), the transport block
%   CRC status CRCOK (true if OK) and the struct INFO with fields
%      SINR          - SINR estimated from the DM-RS, all ports combined (dB), computed
%                      as the ratio between RSRP and NoiseVar.
%      NoiseVar      - Estimated noise variance.
%      TimeAlignment - Estimated time alignment, all ports combined (seconds).
%      RSRP, EPRE    - Estimated RSRP and EPRE, all ports combined (linear).
%      PerPort       - Struct array with the estimator outputs per receive port (RSRP,
%                      EPRE and SINR are linear, TimeAlignment in seconds).
%      H             - Channel estimate (subcarriers x symbols x ports x layers).
%      LLRs          - Codeword soft bits fed to the decoder (int8).
%      LDPCIterationsMax, LDPCIterationsMean - Maximum and average number of LDPC
%                      iterations across the codeblocks.
%
%   The PUSCH must not carry multiplexed UCI, since the chain does not demultiplex it.
%
%   The noise variance passed to the demodulator is the one estimated with all receive
%   ports combined, applied to every port. With strongly unbalanced ports, e.g. a port
%   receiving no signal at all, the noise variance of the active ports is underestimated
%   and the LLRs are overconfident: remove such ports from RXGRID before calling the
%   receiver.
%
%   [...] = ocuduMEX.phy.ocuduPUSCHReceiver(..., NAME=VALUE) specifies the following
%   additional decoding parameters and receiver options:
%      RV                   - Redundancy version (default 0).
%      TBSLBRM              - Limited buffer rate matching TBS in bytes, as logged by
%                             the gNB (default [], meaning unlimited buffer).
%      Smoothing            - Frequency-domain smoothing ('filter' (default), 'mean', 'none').
%      Interpolation        - Time-domain strategy ('interpolate' (default), 'average').
%      CompensateCFO        - Compensate CFO (default false).
%      EqualizerStrategy    - Equalizer ('ZF' (default), 'MMSE').
%      MaxLDPCIterations    - Maximum number of LDPC iterations (default 12).
%
%   Example (on a resource grid dumped by the gNB):
%   T = ocuduParsePUSCHLog('gnb.log');
%   iRow = find(~T.CRCOK & ~isnan(T.RGOffset) & (T.OACK == 0) & (T.OCSI1 == 0), 1);
%   [carrier, pusch, extra] = ocuduParseLogs(Entry=T.Entry{iRow}, SubcarrierSpacing=30, NSizeGrid=273);
%   rxGrid = reshape(ocuduTest.helpers.readComplexFloatFile('samples.iq', T.RGOffset(iRow), ...
%       T.RGSize(iRow)), 12 * carrier.NSizeGrid, carrier.SymbolsPerSlot, []);
%   [bits, crcOK, info] = ocuduMEX.phy.ocuduPUSCHReceiver(carrier, pusch, rxGrid, extra.TargetCodeRate, ...
%       RV=extra.RV, TBSLBRM=extra.TBSLBRM);
%   % The transport block size is computed from the configuration: check it against
%   % the logged one.
%   assert((numel(bits) == extra.TransportBlockLength), 'Inconsistent TBS.');
%
%   See also ocuduMEX.phy.ocuduMultiPortChannelEstimator, ocuduMEX.phy.ocuduPUSCHDemodulator,
%   ocuduMEX.phy.ocuduPUSCHDecoder, nrULSCHDecoder.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
% Portions of this file may implement 3GPP specifications, which may be subject
% to additional licensing requirements.

function [bits, crcOK, info] = ocuduPUSCHReceiver(carrier, pusch, rxGrid, targetCodeRate, options)
    arguments
        carrier                      (1, 1) nrCarrierConfig
        pusch                        (1, 1) nrPUSCHConfig
        rxGrid                       (:, :, :) double
        targetCodeRate               (1, 1) double {mustBePositive, mustBeLessThan(targetCodeRate, 1)}
        options.RV                   (1, 1) double {mustBeMember(options.RV, [0, 1, 2, 3])} = 0
        options.TBSLBRM                     double {mustBeScalarOrEmpty, mustBeInteger, mustBePositive} = []
        options.Smoothing            (1, :) char {mustBeMember(options.Smoothing, {'filter', 'mean', 'none'})} = 'filter'
        options.Interpolation        (1, :) char {mustBeMember(options.Interpolation, {'average', 'interpolate'})} = 'interpolate'
        options.CompensateCFO        (1, 1) logical = false
        options.EqualizerStrategy    (1, :) char {mustBeMember(options.EqualizerStrategy, {'ZF', 'MMSE'})} = 'ZF'
        options.MaxLDPCIterations    (1, 1) double {mustBeInteger, mustBePositive} = 12
    end

    [nSubcarriers, nSymbols, nRxPorts] = size(rxGrid);
    assert((nSubcarriers == 12 * carrier.NSizeGrid) && (nSymbols == carrier.SymbolsPerSlot), ...
        'ocuduPUSCHReceiver:GridSize', 'The resource grid (%d x %d) does not match the carrier (%d x %d).', ...
        nSubcarriers, nSymbols, 12 * carrier.NSizeGrid, carrier.SymbolsPerSlot);

    if (pusch.DMRS.NumCDMGroupsWithoutData == 2)
        betaDMRS = sqrt(2);
    else
        betaDMRS = 1;
    end

    % Channel estimation.
    estimator = ocuduMEX.phy.ocuduMultiPortChannelEstimator( ...
        ImplementationType='MEX', ...
        Smoothing=options.Smoothing, ...
        Interpolation=options.Interpolation, ...
        CompensateCFO=options.CompensateCFO);

    % Strongly quantized grids may have all-zero imaginary parts, which MATLAB stores
    % as real-valued: force a complex-valued grid.
    rxGrid = complex(rxGrid);

    rxPorts = (0:nRxPorts - 1)';
    dmrsIndices = nrPUSCHDMRSIndices(carrier, pusch);
    dmrsSymbols = nrPUSCHDMRS(carrier, pusch);

    [H, noiseVar, estInfo] = estimator(rxGrid, pusch.SymbolAllocation, dmrsIndices, dmrsSymbols, ...
        CyclicPrefix=carrier.CyclicPrefix, ...
        SubcarrierSpacing=carrier.SubcarrierSpacing, ...
        PortIndices=rxPorts, ...
        BetaScaling=betaDMRS);

    % The channel estimate must have dimensions subcarriers x symbols x ports x layers.
    H = reshape(H, nSubcarriers, nSymbols, nRxPorts, pusch.NumLayers);

    % Demodulation.
    demodulator = ocuduMEX.phy.ocuduPUSCHDemodulator(EqualizerStrategy=options.EqualizerStrategy);
    puschIndices = nrPUSCHIndices(carrier, pusch);
    % The estimated noise variance can be exactly zero (e.g., with strongly quantized
    % grids), while the demodulator requires a positive value.
    llrs = demodulator(rxGrid, H, max(noiseVar, realmin('single')), pusch, puschIndices, dmrsIndices, rxPorts);

    % Decoding.
    [segmentCfg, decoderCfg] = ocuduMEX.phy.ocuduPUSCHDecoder.configureSegment(carrier, ...
        pusch, targetCodeRate, 1, 0);
    segmentCfg.RV = options.RV;
    segmentCfg.MaximumLDPCIterationCount = options.MaxLDPCIterations;
    segmentCfg.LimitedBufferSize = computeNref(options.TBSLBRM, segmentCfg.NumCodeblocks);

    decoder = ocuduMEX.phy.ocuduPUSCHDecoder(MaxCodeblockSize=decoderCfg.MaxCodeblockSize, ...
        MaxSoftbuffers=decoderCfg.MaxSoftbuffers, MaxCodeblocks=decoderCfg.MaxCodeblocks);

    harqBufID = struct('RNTI', pusch.RNTI, 'HARQProcessID', 0, 'NumCodeblocks', segmentCfg.NumCodeblocks);
    llrs = int8(llrs);
    [bits, decStats] = decoder(llrs, true, segmentCfg, harqBufID, 'unpacked');
    % Same type as the transport block returned by nrULSCHDecoder.
    bits = int8(bits);
    crcOK = decStats.CRCOK;

    % The estimator returns one entry per port followed by the combined one.
    % The MEX does not fill the combined SINR, compute it from the combined RSRP.
    info = struct('SINR', 10 * log10(estInfo(end).RSRP / noiseVar), 'NoiseVar', noiseVar, ...
        'TimeAlignment', estInfo(end).TimeAlignment, 'RSRP', estInfo(end).RSRP, ...
        'EPRE', estInfo(end).EPRE, 'PerPort', estInfo(1:end-1), 'H', H, 'LLRs', llrs, ...
        'LDPCIterationsMax', decStats.LDPCIterationsMax, 'LDPCIterationsMean', decStats.LDPCIterationsMean);
end % of function ocuduPUSCHReceiver(carrier, pusch, rxGrid, targetCodeRate, options)

function nref = computeNref(tbsLBRM, nCodeblocks)
% Limited buffer rate matching length per codeblock, as in OCUDU ldpc::compute_N_ref
% (zero means unlimited buffer). TBSLBRM is in bytes.
    maxCodeblockSize = 25344;
    nref = 0;
    if ~isempty(tbsLBRM)
        nref = floor(tbsLBRM * 8 * 3 / (2 * nCodeblocks));
        if (nref >= maxCodeblockSize)
            nref = 0;
        end
    end
end % of function computeNref(tbsLBRM, nCodeblocks)
