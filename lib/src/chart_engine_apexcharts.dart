import 'dart:js_interop_unsafe';

import 'package:amdjs/amdjs.dart';
import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:swiss_knife/swiss_knife.dart';
import 'package:web_utils/web_utils.dart';

import 'chart_engine_base.dart';
import 'chart_engine_series.dart';

/// ApexCharts (v3.26.0) Engine.
///
/// Automatically loads `apexcharts.js` using `AMDJS`.
class ChartEngineApexCharts extends ChartEngine {
  // ignore: non_constant_identifier_names
  static final String VERSION = '3.26.0';

  // ignore: non_constant_identifier_names
  static final String PATH = '$CHART_ENGINE_PACKAGE_PATH/apexcharts-$VERSION';

  // ignore: non_constant_identifier_names
  static final String JS_PATH = '$PATH/apexcharts.amd.js';

  // ignore: non_constant_identifier_names
  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js';

  // ignore: non_constant_identifier_names
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

  static JSObject? _jsWrapper;

  /// Loads ApexCharts (`apexcharts.amd.js`) and engine wrapper.
  @override
  Future<bool> load() {
    return _loadController.load(() async {
      var okJS = await AMDJS.require('ApexCharts',
          jsFullPath: JS_PATH, globalJSVariableName: 'ApexCharts');
      var okWrapper = await AMDJS.require(JS_WRAPPER_GLOBAL_NAME,
          jsFullPath: ENGINE_WRAPPER_PATH,
          globalJSVariableName: JS_WRAPPER_GLOBAL_NAME);

      _jsWrapper = globalContext[JS_WRAPPER_GLOBAL_NAME] as JSObject?;

      return okJS && okWrapper;
    });
  }

  ChartEngineApexCharts() {
    Future.microtask(load);
  }

  /// Ensures that DOM element to render is a div. If not will insert a div
  /// inside the element and use it.
  HTMLDivElement asDivElement(Element element) {
    if (element.isA<HTMLDivElement>()) return element as HTMLDivElement;

    var div = HTMLDivElement();
    element.appendChild(div);

    return div;
  }

  static JSObject? _xAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.xAxisMinMax;
    return minMax?.toJSDeep;
  }

  static JSObject? _yAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.yAxisMinMax;
    return minMax?.toJSDeep;
  }

  JSObject? _verticalLines(ChartData chartData) {
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

      return verticalLinesConfig.toJSDeep;
    }

    return null;
  }

  @override
  RenderedApexCharts renderLineChart(
      HTMLElement output, ChartSeries chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartData.options.sortCategories
        ? chartData.seriesSortedByCategory
        : chartData.series;

    series = _reverseSeries(series);

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;

    var renderArgs = [
      div,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      chartData.xLabels.toJSDeep,
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      series.toJSDeep,
      _verticalLines(chartData),
      colors.toJSDeep,
      chartData.options.fillLines,
      chartData.options.straightLines
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderLine'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(this, 'line', chartObject, chartData);
  }

  Map<K, V> _reverseSeries<K, V>(Map<K, V> series) =>
      Map<K, V>.fromEntries(series.entries.toList().reversed);

  @override
  RenderedApexCharts renderTimeSeriesChart(
      HTMLElement output, ChartTimeSeries chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var div = asDivElement(output);

    var timeSeries = chartData.seriesAsPairsOfList(
        sortSeriesByCategory: chartData.options.sortCategories,
        mapDateTimeToMillis: true);

    timeSeries = _reverseSeries(timeSeries);

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;

    var renderArgs = [
      div,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      timeSeries.toJSDeep,
      _verticalLines(chartData),
      colors.toJSDeep,
      chartData.options.fillLines,
      chartData.options.straightLines
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderTimeSeries'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(this, 'time-series', chartObject, chartData);
  }

  @override
  RenderedApexCharts renderBarChart(HTMLElement output, ChartSeries chartData) {
    return _renderBarChartImpl(false, output, chartData);
  }

  @override
  RenderedApexCharts renderHorizontalBarChart(
      HTMLElement output, ChartSeries chartData) {
    return _renderBarChartImpl(true, output, chartData);
  }

  RenderedApexCharts _renderBarChartImpl(
      bool horizontal, HTMLElement output, ChartSeries chartSeries) {
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
      chartSeries.xLabels.toJSDeep,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      set.toJSDeep,
      colors.toJSDeep,
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderBar'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(
        this,
        'bar-${horizontal ? 'horizontal' : 'vertical'}',
        chartObject,
        chartSeries);
  }

  @override
  RenderedApexCharts renderGaugeChart(HTMLElement output, ChartSet chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var div = asDivElement(output);

    var set =
        chartData.options.sortCategories ? chartData.setSorted : chartData.set;

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;

    var renderArgs = [
      div,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      chartData.xLabels.toJSDeep,
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      set.toJSDeep,
      colors.toJSDeep,
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderGauge'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(this, 'gauge', chartObject, chartData);
  }

  @override
  RenderedApexCharts renderScatterChart(
      HTMLElement output, ChartSeriesPair chartSeries) {
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

    var renderArgs = <Object?>[
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      seriesPairs.toJSDeep,
      _verticalLines(chartSeries),
      colors.toJSDeep,
      yMin,
      yMax
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderScatter'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(this, 'scatter', chartObject, chartSeries);
  }

  @override
  RenderedApexCharts renderScatterTimedChart(
      HTMLElement output, ChartTimeSeries chartSeries) {
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

    var renderArgs = <Object?>[
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      timeSeries.toJSDeep,
      _verticalLines(chartSeries),
      colors.toJSDeep,
      yMin,
      yMax,
      true
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderScatter'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedApexCharts(
        this, 'scatter-time-series', chartObject, chartSeries);
  }

  @override
  RenderedApexCharts renderFinancialChart(
      HTMLElement output, ChartTimeSeries chartSeries,
      {bool? ohlc, bool? candlestick}) {
    throw UnsupportedError('Not supported: FinancialChart!');
  }
}

class RenderedApexCharts extends RenderedChart {
  RenderedApexCharts(
      super.engine, super.type, super.chartObject, super.chartData);

  @override
  void refresh() {
    if (!hasChartJSObject) return;
    chartJSObject!.callMethod<JSAny?>('render'.toJS);
  }
}
