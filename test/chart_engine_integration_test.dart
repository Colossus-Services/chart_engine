@TestOn('browser')
library;

import 'package:chart_engine/chart_engine_all.dart';
import 'package:test/test.dart';
import 'package:web_utils/web_utils.dart';

final _d1 = DateTime(2020, 1, 1);
final _d2 = DateTime(2020, 1, 2);
final _d3 = DateTime(2020, 1, 3);

ChartSeries _lineSeries() =>
    ChartSeries(
        ['Jan', 'Feb', 'Mar'],
        {
          'A': [10, 20, 5],
          'B': [15, 25, 55],
          'C': [100, 130, 140],
        },
      )
      ..title = 'Line'
      ..xTitle = 'Month'
      ..yTitle = 'Value';

ChartTimeSeries _timeSeries() => ChartTimeSeries({
  'A': [
    [_d1, 10],
    [_d2, 20],
    [_d3, 15],
  ],
  'B': [
    [_d1, 5],
    [_d3, 25],
  ],
});

ChartSeriesPair _pairSeries() => ChartSeriesPair({
  'A': [
    [1, 10],
    [2, 20],
    [3, 15],
  ],
  'B': [
    [1.5, 5],
    [2.5, 25],
  ],
});

ChartSet _set() => ChartSet({'A': 30, 'B': 70});

ChartTimeSeries _financialSeries() => ChartTimeSeries({
  'A': [
    [_d1, 10, 15, 5, 12],
    [_d2, 12, 18, 10, 17],
    [_d3, 17, 20, 11, 13],
  ],
});

final _outputs = <HTMLElement>[];

HTMLElement _newOutput() {
  var div = HTMLDivElement()
    ..style.width = '600px'
    ..style.height = '400px';
  document.body!.appendChild(div);
  _outputs.add(div);
  return div;
}

/// Waits until [output] contains an element matching [selector].
Future<Element?> _waitFor(HTMLElement output, String selector) async {
  for (var i = 0; i < 50; i++) {
    var e = output.querySelector(selector);
    if (e != null) return e;
    await Future.delayed(Duration(milliseconds: 50));
  }
  return null;
}

typedef _EngineFactory = ChartEngine Function();

void main() {
  tearDown(() {
    for (var o in _outputs) {
      o.remove();
    }
    _outputs.clear();
  });

  final engines = <String, (_EngineFactory, String)>{
    'ChartJS': (ChartEngineChartJS.new, 'canvas'),
    'ApexCharts': (ChartEngineApexCharts.new, 'svg'),
  };

  for (var MapEntry(key: name, value: (factory, renderedSelector))
      in engines.entries) {
    group('ChartEngine[$name]', () {
      late ChartEngine engine;

      setUpAll(() async {
        engine = factory();
        expect(await engine.load(), isTrue);
      });

      Future<void> expectRendered(
        HTMLElement output,
        RenderedChart chart,
        String type,
        ChartData data,
      ) async {
        expect(chart.engine, same(engine));
        expect(chart.type, equals(type));
        expect(chart.chartData, same(data));
        expect(chart.hasChartJSObject, isTrue);
        expect(
          await _waitFor(output, renderedSelector),
          isNotNull,
          reason: 'No `$renderedSelector` rendered for `$type`',
        );
      }

      test('load', () async {
        expect(engine.isLoaded, isTrue);
        expect(engine.version, isNotEmpty);
        expect(() => engine.checkLoaded(), returnsNormally);
        // Loading again is a no-op:
        expect(await engine.load(), isTrue);
      });

      test('renderLineChart', () async {
        var output = _newOutput();
        var data = _lineSeries();
        var chart = engine.renderLineChart(output, data);
        await expectRendered(output, chart, 'line', data);
        expect(data.colors!.keys, equals(['A', 'B', 'C']));
      });

      test('renderLineChart with options', () async {
        var output = _newOutput();
        var data = _lineSeries();
        data.options
          ..sortCategories = true
          ..fillLines = true
          ..straightLines = true
          ..steppedLines = true
          ..yAxisMin = 0
          ..yAxisMax = 200
          ..verticalLines = [
            VerticalLine(1, label: 'Feb'),
            VerticalLine(2, color: '#0000ff'),
          ]
          ..onClick = (a, x, y) {};
        var chart = engine.renderLineChart(output, data);
        await expectRendered(output, chart, 'line', data);
      });

      test('renderTimeSeriesChart', () async {
        var output = _newOutput();
        var data = _timeSeries();
        data.options.verticalLines = [VerticalLine(1, label: 'Day 2')];
        var chart = engine.renderTimeSeriesChart(output, data);
        await expectRendered(output, chart, 'time-series', data);
      });

      test('renderBarChart', () async {
        var output = _newOutput();
        var data = _lineSeries();
        var chart = engine.renderBarChart(output, data);
        await expectRendered(output, chart, 'bar-vertical', data);
      });

      test('renderHorizontalBarChart', () async {
        var output = _newOutput();
        var data = _lineSeries();
        var chart = engine.renderHorizontalBarChart(output, data);
        await expectRendered(output, chart, 'bar-horizontal', data);
      });

      test('renderGaugeChart', () async {
        var output = _newOutput();
        var data = _set();
        var chart = engine.renderGaugeChart(output, data);
        await expectRendered(output, chart, 'gauge', data);
        expect(data.disabledColors, isNotNull);
      });

      test('renderScatterChart', () async {
        var output = _newOutput();
        var data = _pairSeries();
        var chart = engine.renderScatterChart(output, data);
        await expectRendered(output, chart, 'scatter', data);
      });

      test('renderScatterTimedChart', () async {
        var output = _newOutput();
        var data = _timeSeries();
        var chart = engine.renderScatterTimedChart(output, data);
        await expectRendered(output, chart, 'scatter-time-series', data);
      });

      test('render: dispatch by ChartData type', () async {
        final cases = <ChartData, String>{
          _lineSeries(): 'line',
          _timeSeries(): 'time-series',
          _pairSeries(): 'scatter',
          _set(): 'gauge',
        };

        for (var MapEntry(key: data, value: type) in cases.entries) {
          var output = _newOutput();
          var chart = engine.render(output, data)!;
          await expectRendered(output, chart, type, data);
        }
      });

      test('render*Async', () async {
        var output = _newOutput();
        var data = _lineSeries();
        var chart = (await engine.renderAsync(output, data))!;
        await expectRendered(output, chart, 'line', data);

        output = _newOutput();
        var set = _set();
        chart = await engine.renderGaugeChartAsync(output, set);
        await expectRendered(output, chart, 'gauge', set);

        output = _newOutput();
        var pairs = _pairSeries();
        chart = await engine.renderScatterChartAsync(output, pairs);
        await expectRendered(output, chart, 'scatter', pairs);
      });

      test('populateLastRenderedChart', () async {
        var data = _lineSeries()..populateLastRenderedChart = true;
        var chart = engine.renderLineChart(_newOutput(), data);
        expect(data.lastRenderedChart, same(chart));

        var data2 = _lineSeries();
        engine.renderLineChart(_newOutput(), data2);
        expect(data2.lastRenderedChart, isNull);
      });

      test('refresh', () async {
        var output = _newOutput();
        var data = _lineSeries();
        var chart = engine.renderLineChart(output, data);
        await _waitFor(output, renderedSelector);

        data.series['A']![0] = 99;
        expect(() => chart.refresh(), returnsNormally);
        expect(() => chart.refreshDelayed(), returnsNormally);
        await Future.delayed(Duration(milliseconds: 300));
      });

      test('custom colorGenerator', () async {
        var output = _newOutput();
        var data = _lineSeries()
          ..colors = {'A': '#ff0000', 'B': '#00ff00', 'C': '#0000ff'};
        var chart = engine.renderLineChart(output, data);
        await expectRendered(output, chart, 'line', data);
        // User colors are preserved:
        expect(data.colors!['A'], equals('#ff0000'));
      });
    });
  }

  group('ChartEngineChartJS financial', () {
    late ChartEngineChartJS engine;

    setUpAll(() async {
      engine = ChartEngineChartJS();
      expect(await engine.loadFinancial(), isTrue);
      expect(engine.isLoadedFinancial, isTrue);
    });

    test('OHLC (default)', () async {
      var output = _newOutput();
      var data = _financialSeries();
      var chart = engine.renderFinancialChart(output, data);
      expect(chart.type, equals('financial-ohlc'));
      expect(await _waitFor(output, 'canvas'), isNotNull);

      expect(
        () => chart.addOHLC('A', _d3.add(Duration(days: 1)), 13, 16, 9, 14),
        returnsNormally,
      );
    });

    test('Candlestick', () async {
      var output = _newOutput();
      var data = _financialSeries();
      var chart = engine.renderFinancialChart(output, data, candlestick: true);
      expect(chart.type, equals('financial-candlestick'));
      expect(await _waitFor(output, 'canvas'), isNotNull);
    });

    test('addDateValue', () async {
      var output = _newOutput();
      var chart = engine.renderTimeSeriesChart(output, _timeSeries());
      expect(
        () => chart.addDateValue(_d3.add(Duration(days: 1)), 30),
        returnsNormally,
      );
    });

    test('renders into an existing canvas', () async {
      var canvas = HTMLCanvasElement()
        ..width = 300
        ..height = 200;
      var output = _newOutput()..appendChild(canvas);
      engine.renderLineChart(canvas, _lineSeries());
      expect(output.querySelectorAll('canvas').length, equals(1));
    });
  });

  group('ChartEngineApexCharts', () {
    test('financial chart is not supported', () async {
      var engine = ChartEngineApexCharts();
      await engine.load();
      expect(
        () => engine.renderFinancialChart(_newOutput(), _financialSeries()),
        throwsUnsupportedError,
      );
    });
  });

  group('ChartEngineSwitchable', () {
    late ChartEngineChartJS chartJS;
    late ChartEngineApexCharts apex;

    setUpAll(() async {
      chartJS = ChartEngineChartJS();
      apex = ChartEngineApexCharts();
      await chartJS.load();
      await apex.load();
    });

    test('constructor validation', () {
      expect(() => ChartEngineSwitchable({}), throwsArgumentError);
      expect(() => ChartEngineSwitchable({chartJS}), throwsArgumentError);
    });

    test('engine selection', () async {
      var engine = ChartEngineSwitchable({
        chartJS,
        apex,
      }, mainEngineType: ChartEngineChartJS);

      expect(engine.mainEngine, same(chartJS));
      expect(engine.version, equals(ChartEngineChartJS.VERSION));
      expect(engine.getEngineOfType<ChartEngineApexCharts>(), same(apex));
      expect(engine.getEngineByType(ChartEngineChartJS), same(chartJS));

      expect(await engine.load(), isTrue);
      expect(engine.isLoaded, isTrue);

      engine.setMainEngineOfType<ChartEngineApexCharts>();
      expect(engine.mainEngine, same(apex));
      expect(engine.version, equals(ChartEngineApexCharts.VERSION));

      engine.setMainEngineByType(ChartEngineChartJS);
      expect(engine.mainEngine, same(chartJS));
    });

    test('renders with main engine', () async {
      var engine = ChartEngineSwitchable({chartJS, apex}, mainEngine: apex);

      var output = _newOutput();
      var chart = engine.renderLineChart(output, _lineSeries());
      expect(chart, isA<RenderedApexCharts>());
      expect(await _waitFor(output, 'svg'), isNotNull);

      output = _newOutput();
      var gauge = engine.render(output, _set())!;
      expect(gauge, isA<RenderedApexCharts>());
      expect(gauge.type, equals('gauge'));
    });

    test('renderOfEngineType restores main engine', () {
      var engine = ChartEngineSwitchable({chartJS, apex}, mainEngine: apex);

      var chart = engine.renderOfEngineType<ChartEngineChartJS>(
        _newOutput(),
        _lineSeries(),
      );
      expect(chart, isA<RenderedChartJS>());
      expect(engine.mainEngine, same(apex));

      chart = engine.renderWithEngineType(
        ChartEngineChartJS,
        _newOutput(),
        _set(),
      );
      expect(chart, isA<RenderedChartJS>());
      expect(chart!.type, equals('gauge'));
      expect(engine.mainEngine, same(apex));
    });

    test('delegates every chart type', () async {
      var engine = ChartEngineSwitchable({chartJS, apex}, mainEngine: chartJS);

      expect(
        engine.renderTimeSeriesChart(_newOutput(), _timeSeries()).type,
        equals('time-series'),
      );
      expect(
        engine.renderBarChart(_newOutput(), _lineSeries()).type,
        equals('bar-vertical'),
      );
      expect(
        engine.renderHorizontalBarChart(_newOutput(), _lineSeries()).type,
        equals('bar-horizontal'),
      );
      expect(
        engine.renderGaugeChart(_newOutput(), _set()).type,
        equals('gauge'),
      );
      expect(
        engine.renderScatterChart(_newOutput(), _pairSeries()).type,
        equals('scatter'),
      );
      expect(
        engine.renderScatterTimedChart(_newOutput(), _timeSeries()).type,
        equals('scatter-time-series'),
      );

      await chartJS.loadFinancial();
      expect(
        engine
            .renderFinancialChart(_newOutput(), _financialSeries(), ohlc: true)
            .type,
        equals('financial-ohlc'),
      );
    });
  });
}
