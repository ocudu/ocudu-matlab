%ocuduDiagnosticsOutputPlugin - Plugin to show diagnostics to an output stream.
%   The ocuduDiagnosticsOutputPlugin is a simple customization of MATLAB's
%   DiagnosticsOutputPlugin that removes diagnostics due to failed assumptions.
%
%   The ocuduDiagnosticsOutputPlugin enables configuration of a TestRunner to
%   show diagnostics to an output stream. The plugin can be configured to
%   specify the output stream, and the level of detail for displaying the runner
%   events. By default, ocuduDiagnosticsOutputPlugin uses the ToStandardOutput stream,
%   and only includes logged diagnostics at level Verbosity.Terse.
%
%   DiagnosticsOutputPlugin properties:
%       LoggingLevel  - Maximum verbosity level at which logged diagnostics are included
%       OutputDetail  - Verbosity level that defines amount of displayed information
%
%   DiagnosticsOutputPlugin methods:
%       ocuduDiagnosticsOutputPlugin  - Class constructor
%
%   See also matlab.unittest.plugins.DiagnosticsOutputPlugin

% SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
% SPDX-License-Identifier: BSD-3-Clause-Open-MPI

classdef ocuduDiagnosticsOutputPlugin < matlab.unittest.plugins.DiagnosticsOutputPlugin
    methods
        function plugin = ocuduDiagnosticsOutputPlugin(stream, namedargs)
        %ocuduDiagnosticsOutputPlugin - Class constructor
        %   The constructor, in all the following versions, simply calls the
        %   corresponding matlab.unittest.plugins.DiagnosticsOutputPlugin constructor
        %   with the extra name-value arguments
        %   - 'ExcludingFailureDiagnostics', false
        %   - 'IncludingPassingDiagnostics', false
        %
        %   PLUGIN = ocuduDiagnosticsOutputPlugin creates an ocuduDiagnosticsOutputPlugin
        %   instance and returns it in PLUGIN. This plugin can be added to a
        %   TestRunner instance to show failure diagnostics and logged diagnostics
        %   that are logged at level Verbosity.Terse.
        %
        %   PLUGIN = ocuduDiagnosticsOutputPlugin(STREAM) creates an
        %   ocuduDiagnosticsOutputPlugin and redirects the text produced to the
        %   OutputStream STREAM. If STREAM is not supplied, a ToStandardOutput
        %   stream is used.
        %
        %   PLUGIN = ocuduDiagnosticsOutputPlugin(..., 'LoggingLevel', LOGGINGLEVEL)
        %   creates a ocuduDiagnosticsOutputPlugin that includes logged diagnostics that
        %   are logged at or below LOGGINGLEVEL. LOGGINGLEVEL is specified as a
        %   numeric value (0, 1, 2, 3, or 4), a matlab.unittest.Verbosity
        %   enumeration member, or a string or character vector corresponding to
        %   the name of a matlab.unittest.Verbosity enumeration member. To exclude
        %   logged diagnostics, specify LOGGINGLEVEL as Verbosity.None. By default,
        %   LOGGINGLEVEL is Verbosity.Terse.
        %
        %   PLUGIN = DiagnosticsOutputPlugin(..., 'OutputDetail', OUTPUTDETAIL)
        %   creates a DiagnosticsOutputPlugin that displays events with the amount
        %   of output detail specified by OUTPUTDETAIL. OUTPUTDETAIL is specified
        %   as a numeric value (0, 1, 2, 3, or 4), a matlab.unittest.Verbosity
        %   enumeration member, or a string or character vector corresponding to
        %   the name of a matlab.unittest.Verbosity enumeration member. By default,
        %   events are displayed at the Verbosity.Detailed level.
        %
        %   Example:
        %       import matlab.unittest.TestRunner;
        %       import matlab.unittest.TestSuite;
        %       import ocuduTest.plugins.DiagnosticsOutputPlugin;
        %       import matlab.unittest.Verbosity;
        %
        %       % Create a TestSuite array and create a TestRunner with no plugins
        %       suite   = TestSuite.fromClass(?mynamespace.MyTestClass);
        %       runner = TestRunner.withNoPlugins();
        %
        %       % Create an instance of ocuduDiagnosticsOutputPlugin with a terse output detail level
        %       plugin = ocuduDiagnosticsOutputPlugin('OutputDetail',Verbosity.Terse);
        %
        %       % Add the plugin to the TestRunner and run the suite
        %       runner.addPlugin(plugin);
        %       result = runner.run(suite)

            arguments
                stream = matlab.automation.streams.ToStandardOutput
                namedargs.LoggingLevel (1,1) matlab.unittest.Verbosity = matlab.unittest.Verbosity.Terse;
                namedargs.OutputDetail (1,1) matlab.unittest.Verbosity = matlab.unittest.Verbosity.Detailed;
            end

            plugin@matlab.unittest.plugins.DiagnosticsOutputPlugin(stream, ...
                    ExcludingFailureDiagnostics=false, ...
                    IncludingPassingDiagnostics=false, ...
                    LoggingLevel=namedargs.LoggingLevel, ...
                    OutputDetail=namedargs.OutputDetail);
        end
    end

    methods (Hidden, Access=protected)
        function runTestSuite(plugin, pluginData)
        %Overload of DiagnosticsOutputPlugin.runTestSuite that discards "AssumptionFailed"
        %   events.

            import matlab.unittest.internal.plugins.getFailureSummaryTableText;
            plugin.LinePrinter = plugin.createLinePrinter();
            plugin.EventRecordFormatter = plugin.createEventRecordFormatter();
            plugin.EventRecordProcessor = plugin.createEventRecordProcessor();

            % Remove "AssumptionFailed" events from the diagnostics.
            plugin.EventRecordProcessor.TestCaseEvents ...
                    = setdiff(plugin.EventRecordProcessor.TestCaseEvents, "AssumptionFailed");

            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);

            if ~plugin.ExcludeFailureDiagnostics && plugin.OutputDetail > 1
                % Print summary of failures only.
                txt = getFailureSummaryTableText(pluginData.TestResult([pluginData.TestResult.Failed]'));
                if strlength(txt) > 0
                    plugin.LinePrinter.printLine(txt);
                end
            end
        end
    end % of methods (Hidden, Access=protected)

    % Private methods aren't accessible from child classes - copy-pasting the
    % original DiagnosticsOutputPlugin methods.
    methods(Access=private)
        function printer = createLinePrinter(plugin)
            import matlab.unittest.internal.plugins.LinePrinter;
            printer = LinePrinter(plugin.OutputStream);
        end

        function formatter = createEventRecordFormatter(plugin)
            import matlab.unittest.internal.plugins.StandardEventRecordFormatter;
            formatter = StandardEventRecordFormatter();
            formatter.AddDeliminatorsToExceptionEventReport = true;
            formatter.AddDeliminatorsToQualificationEventReport = true;
            formatter.UseAssumptionFailedEventMiniReport = true;
            formatter.ReportVerbosity = plugin.OutputDetail;
        end

        function processor = createEventRecordProcessor(plugin)
            import matlab.unittest.internal.plugins.EventRecordProcessor;
            import matlab.unittest.Verbosity;

            pluginWeakRef = matlab.lang.WeakReference(plugin);
            processor = EventRecordProcessor(@(eventRecord) pluginWeakRef.Handle.processEventRecord(eventRecord));
            if plugin.ExcludeFailureDiagnostics
                processor.removeFailureEvents();
            end
            if plugin.IncludePassingDiagnostics
                processor.addPassingEvents();
            end
            processor.LoggingLevel = plugin.LoggingLevel;
            processor.OutputDetail = plugin.OutputDetail;
        end

        function processEventRecord(plugin,eventRecord)
            reportStr = eventRecord.getFormattedReport(plugin.EventRecordFormatter);
            plugin.LinePrinter.printFormatted(appendNewlineIfNonempty(prependNewlineIfNonempty(reportStr)));
        end
    end
end % of classdef ocuduDiagnosticsOutputPlugin < matlab.unittest.plugins.DiagnosticsOutputPlugin
