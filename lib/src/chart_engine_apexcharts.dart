import 'dart:html';
import 'dart:js';

import 'package:amdjs/amdjs.dart';
import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';
import 'chart_engine_series.dart';

/// ApexCharts (v3.26.0) Engine.
///
/// Automatically loads `apexcharts.js` using `AMDJS`.
class ChartEngineApexCharts extends ChartEngine {
  static final String VERSION = '3.26.0';

  static final String PATH = CHART_ENGINE_PACKAGE_PATH + '/apexcharts-$VERSION';

  static final String JS_PATH = '$PATH/apexcharts.amd.js';

  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js';

  static final String JS_WRAPPER_GLOBAL_NAME =
      '__ChartEngine_Wrapper_ApexCharts__';

  @override
  String get version => VERSION;

  static final LoadController _loadController =
      LoadController('ChartEngineApexCharts');

  @override
  bool get isLoaded =>
      _loadController.isLoaded && _loadController.loadSuccessful!;

  @override
  EventStream<LoadController> get onLoad => _loadController.onLoad;

  static JsObject? _jsWrapper;

  /// Loads ApexCharts (`apexcharts.amd.js`) and engine wrapper.
  @override
  Future<bool> load() {
    return _loadController.load(() async {
      var okJS = await AMDJS.require('ApexCharts',
          jsFullPath: JS_PATH, globalJSVariableName: 'ApexCharts');
      var okWrapper = await AMDJS.require(JS_WRAPPER_GLOBAL_NAME,
          jsFullPath: ENGINE_WRAPPER_PATH,
          globalJSVariableName: JS_WRAPPER_GLOBAL_NAME);

      _jsWrapper = context[JS_WRAPPER_GLOBAL_NAME] as JsObject?;

      return okJS && okWrapper;
    });
  }

  ChartEngineApexCharts() {
    Future.microtask(load);
  }

  /// Ensures that DOM element to render is a div. If not will insert a div
  /// inside the element and use it.
  DivElement asDivElement(Element element) {
    if (element is DivElement) return element;

    var div = DivElement();
    element.children.add(div);

    return div;
  }

  static JsObject? _xAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.xAxisMinMax;
    return minMax != null ? JsObject.jsify(minMax) : null;
  }

  static JsObject? _yAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.yAxisMinMax;
    return minMax != null ? JsObject.jsify(minMax) : null;
  }

  JsObject? _verticalLines(ChartData chartData) {
    var lines = chartData.options.verticalLines;

    if (isNotEmptyObject(lines)) {
      var defColor = chartData.options.verticalLinesDefaultColor;

      var verticalLinesConfig = <Map<String, dynamic>>[];

      for (var i = 0; i < lines!.length; i++) {
        var line = lines[i];
        var idx = line.index;
        var label = line.label ?? '';
        var color = line.color ?? defColor;

        var x = chartData.getXAxisValue(idx);

        var textColor = HTMLColor.from(color)!.greyScale().red > 100
            ? '#000000'
            : '#ffffff';

        verticalLinesConfig.add({
          'x': (x is DateTime ? x.millisecondsSinceEpoch : x),
          'strokeDashArray': 0,
          'borderColor': color,
          'fillColor': color,
          'label': {
            'borderColor': color,
            'style': {
              'background': color,
              'color': textColor,
              'borderColor': color,
            },
            'text': label,
          }
        });
      }

      return JsObject.jsify(verticalLinesConfig);
    }

    return null;
  }

  @override
  RenderedApexCharts renderLineChart(Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    series = _reverseSeries(series);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(series),
      _verticalLines(chartSeries),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines
    ];

    var chartObject = _jsWrapper!.callMethod('renderLine', renderArgs);

    return RenderedApexCharts(this, 'line', chartObject, chartSeries);
  }

  Map<K, V> _reverseSeries<K, V>(Map<K, V> series) =>
      Map<K, V>.fromEntries(series.entries.toList().reversed);

  @override
  RenderedApexCharts renderTimeSeriesChart(
      Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var timeSeries = chartSeries.seriesAsPairsOfList(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    timeSeries = _reverseSeries(timeSeries);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(timeSeries),
      _verticalLines(chartSeries),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines
    ];

    var chartObject = _jsWrapper!.callMethod('renderTimeSeries', renderArgs);

    return RenderedApexCharts(this, 'time-series', chartObject, chartSeries);
  }

  @override
  RenderedApexCharts renderBarChart(Element output, ChartSeries chartData) {
    return _renderBarChartImpl(false, output, chartData);
  }

  @override
  RenderedApexCharts renderHorizontalBarChart(
      Element output, ChartSeries chartData) {
    return _renderBarChartImpl(true, output, chartData);
  }

  RenderedApexCharts _renderBarChartImpl(
      bool horizontal, Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var set = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      horizontal,
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(set),
      JsObject.jsify(colors),
    ];

    var chartObject = _jsWrapper!.callMethod('renderBar', renderArgs);

    return RenderedApexCharts(
        this,
        'bar-${horizontal ? 'horizontal' : 'vertical'}',
        chartObject,
        chartSeries);
  }

  @override
  RenderedApexCharts renderGaugeChart(Element output, ChartSet chartSet) {
    checkRenderParameters(output, chartSet);
    checkLoaded();

    var div = asDivElement(output);

    var set =
        chartSet.options.sortCategories ? chartSet.setSorted : chartSet.set;

    chartSet.ensureColors(colorGenerator);

    var colors = chartSet.colors!;

    var renderArgs = [
      div,
      chartSet.title,
      chartSet.xTitle,
      chartSet.yTitle,
      JsObject.jsify(chartSet.xLabels),
      _xAxisMinMax(chartSet),
      _yAxisMinMax(chartSet),
      JsObject.jsify(set),
      JsObject.jsify(colors),
    ];

    var chartObject = _jsWrapper!.callMethod('renderGauge', renderArgs);

    return RenderedApexCharts(this, 'gauge', chartObject, chartSet);
  }

  @override
  RenderedApexCharts renderScatterChart(
      Element output, ChartSeriesPair chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var seriesPairs = chartSeries.seriesAsPairsOfList(
        sortSeriesByCategory: chartSeries.options.sortCategories);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var yAxisScale = chartSeries.yAxisScale!;

    var yMin = yAxisScale.minimumNice;
    var yMax = yAxisScale.maximumNice;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(seriesPairs),
      _verticalLines(chartSeries),
      JsObject.jsify(colors),
      yMin,
      yMax
    ];

    var chartObject = _jsWrapper!.callMethod('renderScatter', renderArgs);

    return RenderedApexCharts(this, 'scatter', chartObject, chartSeries);
  }

  @override
  RenderedApexCharts renderScatterTimedChart(
      Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var timeSeries = chartSeries.seriesAsPairsOfList(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var yAxisScale = chartSeries.yAxisScale!;

    var yMin = yAxisScale.minimumNice;
    var yMax = yAxisScale.maximumNice;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(timeSeries),
      _verticalLines(chartSeries),
      JsObject.jsify(colors),
      yMin,
      yMax,
      true
    ];

    var chartObject = _jsWrapper!.callMethod('renderScatter', renderArgs);

    return RenderedApexCharts(
        this, 'scatter-time-series', chartObject, chartSeries);
  }

  @override
  RenderedApexCharts renderFinancialChart(
      Element output, ChartTimeSeries chartSeries,
      {bool? ohlc, bool? candlestick}) {
    throw UnsupportedError('Not supported: FinancialChart!');
  }
}

class RenderedApexCharts extends RenderedChart {
  RenderedApexCharts(
      ChartEngine engine, String type, chartObject, ChartData chartData)
      : super(engine, type, chartObject, chartData);

  @override
  void refresh() {
    if (!hasChartJsObject) return;
    chartJsObject!.callMethod('render');
  }
}
