function extendJUnitXML(filename, ocuduCommit, testCommit, urlJob, propertyTag)
%extendJUnitXML adds properties elements to the JUnit-style XML test report.

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI
    arguments
        filename    char {mustBeFile}
        ocuduCommit char {mustBeTextScalar}
        testCommit  char {mustBeTextScalar}
        urlJob      char {mustBeTextScalar}
        propertyTag char {mustBeTextScalar}
    end

    import matlab.io.xml.dom.*

    % Read the xml file.
    docNode = parseFile(Parser, filename);

    % Add properties to testsuites.
    allTestSuiteElements = getElementsByTagName(docNode, "testsuite");

    nTestSuites = allTestSuiteElements.Length;

    for iTestSuite = 1:nTestSuites
        thisTestSuite = node(allTestSuiteElements, iTestSuite);

        % Add ocudu_commit, test_commit and url properties.
        propertiesElement = appendChild(thisTestSuite, createElement(docNode, "properties"));

        propertyOcuduCommit = createElement(docNode, "property");
        setAttribute(propertyOcuduCommit, "name", "ocudu_commit");
        setAttribute(propertyOcuduCommit, "value", ocuduCommit);
        appendChild(propertiesElement, propertyOcuduCommit);

        propertyTestCommit = createElement(docNode, "property");
        setAttribute(propertyTestCommit, "name", "test_commit");
        setAttribute(propertyTestCommit, "value", testCommit);
        appendChild(propertiesElement, propertyTestCommit);

        propertyURL = createElement(docNode, "property");
        setAttribute(propertyURL, "name", "url");
        setAttribute(propertyURL, "value", urlJob);
        appendChild(propertiesElement, propertyURL);
    end

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
