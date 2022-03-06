import 'dart:html';
import 'dart:js';

import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_series.dart';

/// The browser path for package resources.
// ignore: non_constant_identifier_names
final String CHART_ENGINE_PACKAGE_PATH = 'packages/chart_engine';

/// Abstract Chart Engine definition.
abstract class ChartEngine {
  /// `chart_engine` package version.
  // ignore: non_constant_identifier_names
  static final String VERSION = '2.0.3';

  String get version;

  /// Ensures that engine and dependencies are loaded.
  Future<bool> load();

  bool get isLoaded;

  /// onLoad event handler.
  EventStream<LoadController> get onLoad;

  /// Checks if engine is loaded.
  ///
  /// Throws [StateError] if not loaded.
  void checkLoaded() {
    if (!isLoaded) {
      throw StateError('Trying to render before load() engine[$runtimeType]!');
    }
  }

  void checkRenderParameters(Element output, ChartData chartData) {}

  /// Renders at [output] a [chartData], selecting the correct render method.
  RenderedChart? render(Element output, ChartData chartData) {
    _checkOutput(output);

    checkLoaded();

    if (chartData is ChartTimeSeries) {
      return renderTimeSeriesChart(output, chartData);
    } else if (chartData is ChartSeriesPair) {
      return renderScatterChart(output, chartData);
    } else if (chartData is ChartSeries) {
      return renderLineChart(output, chartData);
    } else if (chartData is ChartSet) {
      return renderGaugeChart(output, chartData);
    }

    return null;
  }

  void _checkOutput(Element output) {
    var parent = output.parent;

    if (parent == null) {
      print('WARNING: Chart output has no parent: $output');
    }
  }

  /// The color generator for [ChartData] that doesn't set its own colors.
  ColorGenerator colorGenerator = StandardColorGenerator();

  G getColorGeneratorAs<G extends ColorGenerator>() => colorGenerator as G;

  /// Renders a Line Chart:
  RenderedChart renderLineChart(Element output, ChartSeries chartData);

  /// Renders a Time Series using Line Chart:
  RenderedChart renderTimeSeriesChart(
      Element output, ChartTimeSeries chartData);

  /// Renders a Bar Chart:
  RenderedChart renderBarChart(Element output, ChartSeries chartData);

  /// Renders a Horizontal Bar Chart:
  RenderedChart renderHorizontalBarChart(Element output, ChartSeries chartData);

  /// Renders a Horizontal Bar Chart:
  RenderedChart renderGaugeChart(Element output, ChartSet chartData);

  /// Renders a Scatter Chart with X,Y pairs:
  RenderedChart renderScatterChart(Element output, ChartSeriesPair chartSeries);

  /// Renders a Scatter Chart Timed with DateTime values in X axis:
  RenderedChart renderScatterTimedChart(
      Element output, ChartTimeSeries chartSeries);

  /// Renders financial chart.
  ///
  /// [ohlc] Renders a OHLC chart (default).
  /// [candlestick] Renders a Candlestick chart.
  RenderedChart renderFinancialChart(
      Element output, ChartTimeSeries chartSeries,
      {bool? ohlc, bool? candlestick});

  Future _ensureLoaded() async {
    if (!isLoaded) {
      await load();
    }
  }

  /// Same as [render], but [async].
  Future<RenderedChart?> renderAsync(
      Element output, ChartData chartData) async {
    await _ensureLoaded();
    return render(output, chartData);
  }

  /// Same as [renderLineChart], but [async].
  Future<RenderedChart> renderLineChartAsync(
      Element output, ChartSeries chartData) async {
    await _ensureLoaded();
    return renderLineChart(output, chartData);
  }

  /// Same as [renderTimeSeriesChart], but [async].
  Future<RenderedChart> renderTimeSeriesChartAsync(
      Element output, ChartTimeSeries chartData) async {
    await _ensureLoaded();
    return renderTimeSeriesChart(output, chartData);
  }

  /// Same as [renderBarChart], but [async].
  Future<RenderedChart> renderBarChartAsync(
      Element output, ChartSeries chartData) async {
    await _ensureLoaded();
    return renderBarChart(output, chartData);
  }

  /// Same as [renderHorizontalBarChart], but [async].
  Future<RenderedChart> renderHorizontalBarChartAsync(
      Element output, ChartSeries chartData) async {
    await _ensureLoaded();
    return renderHorizontalBarChart(output, chartData);
  }

  /// Same as [renderGaugeChart], but [async].
  Future<RenderedChart> renderGaugeChartAsync(
      Element output, ChartSet chartData) async {
    await _ensureLoaded();
    return renderGaugeChart(output, chartData);
  }

  /// Same as [renderScatterChart], but [async].
  Future<RenderedChart> renderScatterChartAsync(
      Element output, ChartSeriesPair chartSeries) async {
    await _ensureLoaded();
    return renderScatterChart(output, chartSeries);
  }

  /// Same as [renderScatterTimedChart], but [async].
  Future<RenderedChart> renderScatterTimedChartAsync(
      Element output, ChartTimeSeries chartSeries) async {
    await _ensureLoaded();
    return renderScatterTimedChart(output, chartSeries);
  }
}

/// A ChartEngine wrapper with switchable internal engines:
class ChartEngineSwitchable extends ChartEngine {
  final Set<ChartEngine> engines;

  @override
  String get version => mainEngine!.version;

  ChartEngine? _mainEngine;

  ChartEngineSwitchable(this.engines,
      {Type? mainEngineType, ChartEngine? mainEngine}) {
    if (engines.isEmpty) throw ArgumentError('Should have 1 or more engines');

    if (mainEngine != null) {
      _mainEngine = mainEngine;
    } else if (mainEngineType != null) {
      _mainEngine = getEngineByType(mainEngineType);
    } else {
      throw ArgumentError('No main engine defined in arguments.');
    }

    for (var engine in engines) {
      engine.onLoad.listen((event) {
        if (isLoaded) {
          onLoad.add(event);
        }
      });
    }
  }

  /// The current main ChartEngine/
  ChartEngine? get mainEngine => _mainEngine;

  /// Sets the main ChartEngine to use, selected by [engineType].
  ChartEngine setMainEngineByType(Type engineType) {
    return _mainEngine = getEngineByType(engineType);
  }

  /// Sets the main ChartEngine to use, selected by [T].
  ChartEngine setMainEngineOfType<T>() {
    return _mainEngine = getEngineOfType<T>();
  }

  /// Gets an engine selected with [T].
  ChartEngine getEngineOfType<T>() {
    return engines.firstWhere((e) => (e is T));
  }

  /// Gets an engine selected with [engineType].
  ChartEngine getEngineByType(Type engineType) {
    return engines.firstWhere((e) => e.runtimeType == engineType);
  }

  @override
  String toString() {
    return 'ChartEngineSwitchable{engines: $engines}';
  }

  @override
  bool get isLoaded =>
      listMatchesAll(engines.map((e) => e.isLoaded), (bool r) => r);

  @override
  Future<bool> load() async {
    var loads = engines.map((e) => e.load());
    var results = await Future.wait(loads);
    return listMatchesAll(results, (bool r) => r);
  }

  @override
  EventStream<LoadController> get onLoad => EventStream();

  /// Renders using engine of [engineType].
  RenderedChart? renderWithEngineType(
      Type engineType, Element output, ChartData chartData) {
    var prevMainEngine = _mainEngine;
    setMainEngineByType(engineType);
    var ok = render(output, chartData);
    _mainEngine = prevMainEngine;
    return ok;
  }

  /// Renders using engine of type [T].
  RenderedChart? renderOfEngineType<T>(Element output, ChartData chartData) {
    var prevMainEngine = _mainEngine;
    setMainEngineOfType<T>();
    var ok = render(output, chartData);
    _mainEngine = prevMainEngine;
    return ok;
  }

  @override
  RenderedChart renderLineChart(Element output, ChartSeries chartData) {
    return mainEngine!.renderLineChart(output, chartData);
  }

  @override
  RenderedChart renderTimeSeriesChart(Element output, ChartSeries chartData) {
    return mainEngine!.renderTimeSeriesChart(
        output, chartData as ChartTimeSeries<dynamic, dynamic>);
  }

  @override
  RenderedChart renderBarChart(Element output, ChartSeries chartData) {
    return mainEngine!.renderBarChart(output, chartData);
  }

  @override
  RenderedChart renderHorizontalBarChart(
      Element output, ChartSeries chartData) {
    return mainEngine!.renderHorizontalBarChart(output, chartData);
  }

  @override
  RenderedChart renderGaugeChart(Element output, ChartSet chartData) {
    return mainEngine!.renderGaugeChart(output, chartData);
  }

  @override
  RenderedChart renderScatterChart(
      Element output, ChartSeriesPair chartSeries) {
    return mainEngine!.renderScatterChart(output, chartSeries);
  }

  @override
  RenderedChart renderScatterTimedChart(
      Element output, ChartTimeSeries chartSeries) {
    return mainEngine!.renderScatterTimedChart(output, chartSeries);
  }

  @override
  RenderedChart renderFinancialChart(
      Element output, ChartTimeSeries chartSeries,
      {bool? ohlc, bool? candlestick}) {
    return mainEngine!.renderFinancialChart(output, chartSeries,
        ohlc: ohlc, candlestick: candlestick);
  }
}

/// Represents a rendered chart.
abstract class RenderedChart {
  final ChartEngine engine;
  final String type;
  final dynamic chartObject;
  final ChartData chartData;

  late InteractionCompleter _interactionCompleter;

  RenderedChart(this.engine, this.type, this.chartObject, this.chartData) {
    _interactionCompleter = InteractionCompleter('RenderedChart:refreshDelayed',
        triggerDelay: Duration(milliseconds: 200),
        functionToTrigger: () => refresh());

    if (chartData.populateLastRenderedChart) {
      chartData.lastRenderedChart = this;
    }
  }

  JsObject? get chartJsObject => chartObject is JsObject ? chartObject : null;

  bool get hasChartJsObject => chartJsObject != null;

  @override
  String toString() {
    return '$runtimeType{engine: $engine, type: $type, chartObject: $chartObject, chartData: $chartData}';
  }

  /// Refreshes the rendered chart.
  void refresh();

  /// Refreshes the rendered chart with a delay (consecutive calls are ignored).
  void refreshDelayed() {
    _interactionCompleter.interact();
  }
}
