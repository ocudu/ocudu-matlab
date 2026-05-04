function extendJUnitXML(filename, propertyTag)
%extendJUnitXML adds a properies element to the JUnit-style XML test report.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
    arguments
        filename    char {mustBeFile}
        propertyTag char {mustBeTextScalar}
    end

    import matlab.io.xml.dom.*

    % Read the xml file.
    docNode = parseFile(Parser, filename);

    % Find all 'testcase' elements.
    allTestCaseElements = getElementsByTagName(docNode, "testcase");

    nTestCases = allTestCaseElements.Length;

    for iTestCase = 1:nTestCases
        thisTestCase = node(allTestCaseElements, iTestCase);

        % Add a property and set the 'markers' attribute to the given value.
        propertiesElement = appendChild(thisTestCase, createElement(docNode, "properties"));

        propertyMarkers = createElement(docNode, "property");
        setAttribute(propertyMarkers, "name", "markers");
        setAttribute(propertyMarkers, "value", propertyTag);
        appendChild(propertiesElement, propertyMarkers);
    end

    % Write the updated xml file.
    writer = DOMWriter;
    writer.Configuration.FormatPrettyPrint = true;
    writeToFile(writer, docNode, filename);
end % of function testxml(filename)
