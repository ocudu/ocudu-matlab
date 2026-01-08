%runOCUDUunittest Main OCUDU test interface.
%   runOCUDUunittest(BLOCKNAME, 'testvector') generates test vectors for the
%   OCUDU block BLOCKNAME. The resulting test vectores are stored in the folder
%   'testvectorOutputs' in the current directory. Example:
%      runOCUDUunittest('modulation_mapper', 'testvector')
%
%   runOCUDUunittest(BLOCKNAME, 'testmex') tests the OCUDU block
%   BLOCKNAME by running a MEX version of it.
%
%   runOCUDUunittest(..., RandomShuffle=true) runs the tests using the 'shuffle'
%   random generator initialization instead of 'default'.
%
%   runOCUDUunittest('all', ...) runs all the tests of the specified type.
%
%   TEST = runOCUDUunittest(...) returns a Test object TEST withouth running it.
%   The test can be later executed with the command TEST.run.
%
%   [TEST, RUNNER] = runOCUDUunittest(...) also returns a TestRunner with
%   suitable settings for the generated test suite.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [test, runner] = runOCUDUunittest(blockName, testType, opt)
    arguments
        blockName          char   {mustBeOCUDUBlock}
        testType           char   {mustBeMember(testType, {'testvector', 'testmex'})}
        opt.RandomShuffle logical {mustBeNumericOrLogical} = false
    end

    import matlab.unittest.TestSuite
    import matlab.unittest.parameters.Parameter

    % Define the absolute output paths.
    outputPath = [pwd '/testvectorOutputs'];
    extParams = Parameter.fromData('outputPath', {outputPath}, 'RandomDefault', {~opt.RandomShuffle});

    % Normally, use the default runner that shows all diagnostics.
    runner = matlab.unittest.TestRunner.withDefaultPlugins;

    if ~strcmp(blockName, 'all')
        unittestClass = name2Class(blockName);
        nrPHYtestvectorTests = TestSuite.fromClass(unittestClass, ...
            'Tag', testType, 'ExternalParameters', extParams);
        if isempty(nrPHYtestvectorTests)
            warning('No ''%s'' tests for the ''%s'' block.', testType, blockName);
        end
    else
        nrPHYtestvectorTests = TestSuite.fromFolder('.', 'Tag', testType, ...
            'ExternalParameters', extParams);

        % When running the tests for all blocks, replace the DiagnosticsOutputPlugin
        % with a modified version that does not show diagnostics caused by failed
        % assumptions, if supported.
        if ~isMATLABReleaseOlderThan('R2024b')
            runner = matlab.unittest.TestRunner.withNoPlugins;
            runner.addPlugin(ocuduTest.plugins.ocuduDiagnosticsOutputPlugin);
            runner.addPlugin(matlab.unittest.plugins.TestRunProgressPlugin.withVerbosity("Concise"));
            runner.addPlugin(matlab.unittest.plugins.DiagnosticsRecordingPlugin);
        end
    end
    if nargout >= 1
        test = nrPHYtestvectorTests;
    else
        test = runner.run(nrPHYtestvectorTests);
    end % of if nargout >= 1
end % of runOCUDUunittest

function mustBeOCUDUBlock(a)
    validBlocks = union({'all'}, ocuduTest.listOCUDUblocks);
    mustBeMember(a, validBlocks);
end

function unittestClass = name2Class(name)
    switch name
        case 'channel_equalizer'
            unittestClass = ?ocuduChEqualizerUnittest;
        case 'demodulation_mapper'
            unittestClass = ?ocuduDemodulationMapperUnittest;
        case 'dft_processor'
            unittestClass = ?ocuduDFTProcessorUnittest;
        case 'dmrs_pbch_processor'
            unittestClass = ?ocuduPBCHDMRSUnittest;
        case 'dmrs_pdcch_processor'
            unittestClass = ?ocuduPDCCHDMRSUnittest;
        case 'dmrs_pdsch_processor'
            unittestClass = ?ocuduPDSCHDMRSUnittest;
        case 'dmrs_pucch_estimator'
            unittestClass = ?ocuduPUCCHDMRSUnittest;
        case 'dmrs_pusch_estimator'
            unittestClass = ?ocuduPUSCHDMRSUnittest;
        case 'ldpc_encoder'
            unittestClass = ?ocuduLDPCEncoderUnittest;
        case 'ldpc_rate_matcher'
            unittestClass = ?ocuduLDPCRateMatcherUnittest;
        case 'ldpc_segmenter'
            unittestClass = ?ocuduLDPCSegmenterUnittest;
        case 'low_papr_sequence_generator'
            unittestClass = ?ocuduLowPAPRSequenceUnittest;
        case 'modulation_mapper'
            unittestClass = ?ocuduModulationMapperUnittest;
        case 'nzp_csi_rs_generator'
            unittestClass = ?ocuduNZPCSIRSGeneratorUnittest;
        case 'ofdm_demodulator'
            unittestClass = ?ocuduOFDMDemodulatorUnittest;
        case 'ofdm_modulator'
            unittestClass = ?ocuduOFDMModulatorUnittest;
        case 'ofdm_prach_demodulator'
            unittestClass = ? ocuduPRACHDemodulatorUnittest;
        case 'ofh_compression'
            unittestClass = ?ocuduOFHCompressionUnittest;
        case 'pbch_encoder'
            unittestClass = ?ocuduPBCHEncoderUnittest;
        case 'pbch_modulator'
            unittestClass = ?ocuduPBCHModulatorUnittest;
        case 'pdcch_candidates_common'
            unittestClass = ?ocuduPDCCHCandidatesCommonUnittest;
        case 'pdcch_candidates_ue'
            unittestClass = ?ocuduPDCCHCandidatesUeUnittest;
        case 'pdcch_encoder'
            unittestClass = ?ocuduPDCCHEncoderUnittest;
        case 'pdcch_modulator'
            unittestClass = ?ocuduPDCCHModulatorUnittest;
        case 'pdcch_processor'
            unittestClass = ?ocuduPDCCHProcessorUnittest;
        case 'pdsch_encoder'
            unittestClass = ?ocuduPDSCHEncoderUnittest;
        case 'pdsch_modulator'
            unittestClass = ?ocuduPDSCHModulatorUnittest;
        case 'pdsch_processor'
            unittestClass = ?ocuduPDSCHProcessorUnittest;
        case 'port_channel_estimator'
            unittestClass = ?ocuduChEstimatorUnittest;
        case 'prach_configuration'
            unittestClass = ?ocuduPRACHConfigurationUnittest;
        case 'prach_detector'
            unittestClass = ?ocuduPRACHDetectorUnittest;
        case 'prach_generator'
            unittestClass = ?ocuduPRACHGeneratorUnittest;
        case 'prach_scheduler'
            unittestClass = ?ocuduPRACHSchedulerUnittest;
        case 'prs_generator'
            unittestClass = ?ocuduPRSGeneratorUnittest;
        case 'ptrs_pdsch_generator'
            unittestClass = ?ocuduPDSCHPTRSGeneratorUnittest;
        case 'pucch_demodulator_format2'
            unittestClass = ?ocuduPUCCHDemodulatorFormat2Unittest;
        case 'pucch_demodulator_format3'
            unittestClass = ?ocuduPUCCHDemodulatorFormat3Unittest;
        case 'pucch_demodulator_format4'
            unittestClass = ?ocuduPUCCHDemodulatorFormat4Unittest;
        case 'pucch_processor_format0'
            unittestClass = ?ocuduPUCCHProcessorFormat0Unittest;
        case 'pucch_processor_format1'
            unittestClass = ?ocuduPUCCHProcessorFormat1Unittest;
        case 'pucch_processor_format2'
            unittestClass = ?ocuduPUCCHProcessorFormat2Unittest;
        case 'pucch_processor_format3'
            unittestClass = ?ocuduPUCCHProcessorFormat3Unittest;
        case 'pucch_processor_format4'
            unittestClass = ?ocuduPUCCHProcessorFormat4Unittest;
        case 'pusch_decoder'
            unittestClass = ?ocuduPUSCHDecoderUnittest;
        case 'pusch_demodulator'
            unittestClass = ?ocuduPUSCHDemodulatorUnittest;
        case 'pusch_processor'
            unittestClass = ?ocuduPUSCHProcessorUnittest;
        case 'pusch_tpmi_select'
            unittestClass = ?ocuduTPMISelectUnittest;
        case 'short_block_detector'
            unittestClass = ?ocuduShortBlockDetectorUnittest;
        case 'short_block_encoder'
            unittestClass = ?ocuduShortBlockEncoderUnittest;
        case 'srs_estimator'
            unittestClass = ?ocuduSRSEstimatorUnittest;
        case 'ssb_processor'
            unittestClass = ?ocuduSSBProcessorUnittest;
        case 'tbs_calculator'
            unittestClass = ?ocuduTBSCalculatorUnittest;
        case 'transform_precoder'
            unittestClass = ?ocuduTransformPrecoderUnittest;
        case 'uci_decoder'
            unittestClass = ?ocuduUCIDecoderUnittest;
        case 'ulsch_demultiplex'
            unittestClass = ?ocuduULSCHDemultiplexUnittest;
        case 'ulsch_info'
            unittestClass = ?ocuduULSCHInfoUnittest;
        otherwise
            error('ocudu_matlab:runOCUDUunittest:unknownBlock', ...
                'No unit test for block %s.\n', name);
    end
end
