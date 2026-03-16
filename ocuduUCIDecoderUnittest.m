%ocuduUCIDecoderUnittest Unit tests for UCI decoder functions.
%   This class implements unit tests for Uplink Control Information (UCI) decoder
%   functions using the matlab.unittest framework. The simplest use consists in
%   creating an object with testCase = ocuduUCIDecoderUnittest and then running all
%   the tests with
%      testResults = testCase.run
%
%   ocuduUCIDecoderUnittest Properties (Constant):
%
%   ocuduBlock      - The tested block (i.e., 'uci_decoder').
%   ocuduBlockType  - The type of the tested block, including layer
%                     (i.e., 'phy/upper/channel_processors').
%
%   ocuduUCIDecoderUnittest Properties (ClassSetupParameter):
%
%   outputPath - Path to the folder where the test results are stored.
%
%   ocuduUCIDecoderUnittest Properties (TestParameter):
%
%   A                       - Length in bits of the UCI message.
%   Modulation               - Modulation scheme.
%
%   ocuduUCIDecoderUnittest Methods (TestTags = {'testvector'}):
%
%   testvectorGenerationCases - Generates a test vector according to the provided
%                               parameters.
%
%   ocuduUCIDecoderUnittest Methods (Access = protected):
%
%   addTestIncludesToHeaderFile     - Adds include directives to the test header file.
%   addTestDefinitionToHeaderFile   - Adds details (e.g., type/variable declarations)
%                                     to the test header file.
%
%   See also matlab.unittest, nrPUSCHDecode.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduUCIDecoderUnittest < ocuduTest.ocuduBlockUnittest
    properties (Constant)
        %Name of the tested block.
        ocuduBlock = 'uci_decoder'

        %Type of the tested block.
        ocuduBlockType = 'phy/upper/channel_processors/uci'
    end

    properties (ClassSetupParameter)
        %Path to results folder (old 'uci_decoder' tests will be erased).
        outputPath = {['testUCIDecoder', char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'))]}
    end

    properties (TestParameter)
        %Length in bits of the UCI message. Four different cases are covered: single
        %   UCI bit (1), two UCI bits (2), length between 3 and 11 UCI bits (3-11)
        %   and length between 12 and 1706 UCI bits (12-1706).
        A = [num2cell(1:12) {19, 20, 200, 1706}]

        %Modulation scheme.
        Modulation = {'pi/2-BPSK', 'QPSK', '16QAM', '64QAM', '256QAM'}

        %Code rate.
        Rate= {0.1, 2/3}
    end

    methods (Access = protected)
        function addTestIncludesToHeaderFile(~, fileID)
        %addTestIncludesToHeaderFile Adds include directives to the test header file.

            fprintf(fileID, '#include "ocudu/phy/upper/channel_processors/uci/uci_decoder.h"\n');
            fprintf(fileID, '#include "ocudu/phy/upper/log_likelihood_ratio.h"\n');
            fprintf(fileID, '#include "ocudu/ran/sch/modulation_scheme.h"\n');
            fprintf(fileID, '#include "ocudu/support/file_vector.h"\n');
        end

        function addTestDefinitionToHeaderFile(~, fileID)
        %addTestDetailsToHeaderFile Adds details (e.g., type/variable declarations) to the test header file.

            fprintf(fileID, 'struct test_case_t {\n');
            fprintf(fileID, '  unsigned                          message_length = 0;\n');
            fprintf(fileID, '  unsigned                          llr_length     = 0;\n');
            fprintf(fileID, '  uci_decoder::configuration        config;\n');
            fprintf(fileID, '  file_vector<uint8_t>              message;\n');
            fprintf(fileID, '  file_vector<log_likelihood_ratio> llr;\n');
            fprintf(fileID, '};\n');
        end

    end % of methods (Access = protected)

    methods (Test, TestTags = {'testvector'})

        function testvectorGenerationCases(testCase, A, Modulation, Rate)
        %testvectorGenerationCases Generates a test vector for the given A and
        %   Modulation and Rate. Other parameters (e.g., E) are generated randomly.

            import ocuduLib.phy.helpers.ocuduGetBitsSymbol
            import ocuduLib.phy.helpers.ocuduModulationFromMatlab
            import ocuduTest.helpers.writeUint8File
            import ocuduTest.helpers.writeInt8File

            % Generate a unique test ID.
            testID = testCase.generateTestID;

            % Set randomized values.
            UCIbits = randi([0 1], A, 1);

            % Get the number of bits per symbol
            bitsSymbol = ocuduGetBitsSymbol(Modulation);
            
            % The length of the rate-matched UCI codeword, E, depends on A 
            % and on the modulation scheme (maximum length = 8192).
            minE = A + 1;
            maxE = floor(8192 / bitsSymbol) * bitsSymbol;

            % For sequence sizes in {12,..., 19} bits there will be 6 CRC
            % bits, for longer sequences there will be 11 CRC bits.
            % If A > 2 and < 12 assign a minE of 24 in order to be able to decode it.
            L = 0;
            if A > 19
                L = 11;
            elseif A > 11
                L = 6;
            elseif A > 2
                minE = 24;
            end

            % If a second polar code codeblock is used, the maximum number
            % of rate matched bits is doubled.
            if A > 1013
                maxE = 2 * maxE;
                L = 2 * L;
            end
            minE  = minE + L;

            % Select a number of rate macthed bits without exceeding the maximum. 
            E = min(maxE, max(minE, ceil((A + L) / Rate)));
    
            % Round the number of rate macthed bits to the number of bits
            % per symbol.
            E = ceil(E / bitsSymbol) * bitsSymbol;

            % Set up an SNR that can challenge the decoder.
            snrdB = 25;
            nVar = 10 ^ (-snrdB / 10);
            
            % Encode the UCI bits.
            UCICodeWord = nrUCIEncode(UCIbits, E, Modulation);

            % Replace placeholders -1 (x) and -2 (y) as part of the
            % descrambling.
            UCICodeWord(UCICodeWord == -1) = 1;
            UCICodeWord(UCICodeWord == -2) = UCICodeWord(find(UCICodeWord == -2) - 1);

            % Modulate signal.
            modulatedUCI = nrSymbolModulate(UCICodeWord, Modulation);

            % Apply AWGN and try to decode. Repeat process until it is 
            % possible to decode.
            decodedOk = false;
            while ~decodedOk
                % Estimate the LLR soft bits.
                rxSignal = awgn(modulatedUCI, snrdB);
                LLRSoftBits = nrSymbolDemodulate(rxSignal, Modulation, nVar);
    
                % Decode the received UCI LLR soft bits.
                decodedUCIBits = nrUCIDecode(LLRSoftBits, A, Modulation);

                % Check if the message is decoded.
                decodedOk = (sum(xor(UCIbits, decodedUCIBits)) == 0);
           
            end

            % Clip and quantize the LLRs.
            LLRSoftBits(LLRSoftBits > 20) = 20;
            LLRSoftBits(LLRSoftBits < -20) = -20;
            LLRSoftBits = round(LLRSoftBits * 6); % this is LLRSoftBits * 120 / 20
            % Write the LLRs to a binary file.
            testCase.saveDataFile('_test_input', testID, @writeInt8File, LLRSoftBits(:));

            % Write the decoded UCI message to a binary file.
            testCase.saveDataFile('_test_output', testID, @writeUint8File, UCIbits);

            % Generate the test case entry.
            testCaseString = testCase.testCaseToString(testID, ...
                {A, E, {ocuduModulationFromMatlab(Modulation, 'full')}}, ...
                false, '_test_output', '_test_input');

            % Add the test to the file header.
            testCase.addTestToHeaderFile(testCase.headerFileID, testCaseString);
        end % of function testvectorGenerationCases
    end % of methods (Test, TestTags = {'testvector'})
end % of classdef ocuduUCIDecoderUnittest
