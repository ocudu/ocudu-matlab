%ocuduGetUniqueSymbolsIndices Puts all unique symbol and index pairs of a cell in vector format.
%   [SYMBOLVECTOR, SYMBOLINDICESVECTOR] = ocuduGetUniqueSymbolsIndices(SYMBOLS, SYMBOLINDICES)
%   returns a vector with complex symbols SYMBOLVECTOR and a vector with the relate indices,
%   making sure that no repeated entries are present. The input arguments are a cell structure
%   comprising several sets of symbols and indices.

%
%   Copyright 2021-2026 Software Radio Systems Limited
%
%   By using this file, you agree to the terms and conditions set
%   forth in the LICENSE file which can be found at the top level of
%   the distribution.
%

function [symbolVector, symbolIndicesVector] = ocuduGetUniqueSymbolsIndices(symbols, symbolIndices)

    % initialize the output vectors
    symbolVector = zeros(1, 1);
    symbolIndicesVector = zeros(1, 3);

    % find the number of sets of symbols and indices
    nofSets = size(symbols, 1);
    tmpVector = zeros(1, 3);
    nofAddedValues = 0;
    for setIdx = 1:nofSets
        symbolSet = symbols{setIdx};
        indicesSet = symbolIndices{setIdx};

        % find the size of each set
        [nofSymbols, nofSubsets] = size(symbolSet);
        for subsetIdx = 1:nofSubsets
            symbolSubset = symbolSet(:, subsetIdx);
            indicesSubset = indicesSet(:, :, subsetIdx);

            % check if the current symbol is already included in the output vector
            for symbolIx = 1:nofSymbols
                tmpVector(:) = indicesSubset(symbolIx, :);
                valueNotInVector = true;
                if nofAddedValues > 0
                    for tmpIndex = 1:nofAddedValues
                        if isequal(tmpVector(:), symbolIndicesVector(tmpIndex, :).')
                            valueNotInVector = false;
                        end
                    end
                end

                % add a new unique value to the output vectors
                if valueNotInVector
                  nofAddedValues = nofAddedValues + 1;
                  symbolVector(nofAddedValues, 1) = symbolSubset(symbolIx);
                  symbolIndicesVector(nofAddedValues, :) = tmpVector(:);
                end
            end
        end
    end
end
