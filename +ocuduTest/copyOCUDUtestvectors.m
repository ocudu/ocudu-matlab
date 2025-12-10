%copyOCUDUtestvectors Copy test vector files.
%   copyOCUDUtestvectors(ORIGIN, DESTINATION) copies all test vector files (both
%   header files and tar.gz files) found in folder ORIGIN to the proper
%   subfolder of DESTINATION. Here, DESTINATION stands for a root directory of
%   the OCUDU software.
%
%   copyOCUDUtestvectors(ORIGIN, DESTINATION, BLOCK) copies only the test vectors
%   corresponding to the OCUDU block BLOCK.
%
%   copyOCUDUtestvectors(ORIGIN, DESTINATION, BLOCK, OCUDUDIR) specifies OCUDUDIR as
%   the ocudu_matlab root directory (defaults to current directory).

%   Copyright 2021-2025 Software Radio Systems Limited
%
%   This file is part of OCUDU-matlab.
%
%   OCUDU-matlab is free software: you can redistribute it and/or
%   modify it under the terms of the BSD 2-Clause License.
%
%   OCUDU-matlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%   BSD 2-Clause License for more details.
%
%   A copy of the BSD 2-Clause License can be found in the LICENSE
%   file in the top-level directory of this distribution.

function copyOCUDUtestvectors(origin, destination, targetBlock, ocuduDir)
    arguments
        origin      (1, :) char {mustBeFolder}
        destination (1, :) char {mustBeFolder}
        targetBlock (1, :) char {mustBeOCUDUBlock} = 'all'
        ocuduDir    (1, :) char {mustBeFolder}   = '.'
    end

    % Find all .m files in the working directory.
    tmp = what(ocuduDir);
    filesDotM = tmp.m;
    nFiles = length(filesDotM);

    % For all .m files...
    for iFile = 1:nFiles
        thisFile = filesDotM{iFile};
        % ensure the file is a class
        thisClass = meta.class.fromName(thisFile(1:end-2));
        if isempty(thisClass)
            continue;
        end
        classProperties = thisClass.PropertyList;
        % ensure the class has the properties ocuduBlock and ocuduBlockType
        [~, blockIdx] = ismember('ocuduBlock', {classProperties.Name});
        [~, typeIdx] = ismember('ocuduBlockType', {classProperties.Name});
        if (blockIdx * typeIdx == 0)
            continue;
        end
        block = classProperties(blockIdx).DefaultValue;
        blockType = classProperties(typeIdx).DefaultValue;

        % if the block is the targeted one (or if we target all blocks)
        if ismember(targetBlock, {'all', block})
            % create file names
            headerFile = fullfile(origin, [block '_test_data.h']);
            tarFile = fullfile(origin, [block '_test_data.tar.gz']);
            finalDest = fullfile(destination, blockType);

            % ensure the finalDest exists
            if (~exist(finalDest, "dir"))
                try
                    mkdir(finalDest);
                catch
                    warning('Cannot create folder %s.', finalDest);
                end
            end

            % copy files to finalDest
            if exist(headerFile, 'file') == 2
                try
                    copyfile(headerFile, finalDest);
                catch
                    warning('Header file %s could not be copied to %s.', headerFile, finalDest);
                end
            end
            if exist(tarFile, 'file') == 2
                try
                    copyfile(tarFile, finalDest);
                catch
                    warning('Test vectors file %s could not be copied to %s.', tarFile, finalDest);
                end
            end
        end % of if ismember
    end % of for iFile
end % of function

function mustBeOCUDUBlock(a)
    validBlocks = union({'all'}, ocuduTest.listOCUDUblocks);
    mustBeMember(a, validBlocks);
end

