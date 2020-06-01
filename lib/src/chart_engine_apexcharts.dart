import 'dart:html';
import 'dart:js';

import 'package:amdjs/amdjs.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';
import 'chart_engine_colors.dart';
import 'chart_engine_series.dart';

/// ApexCharts (v3.19.0) Engine.
///
/// Automatically loads `apexcharts.js` using `AMDJS`.
class ChartEngineApexCharts extends ChartEngine {
  static final String VERSION = '3.19.0';

  static final String PATH = CHART_ENGINE_PACKAGE_PATH + '/apexcharts-$VERSION';

  static final String JS_PATH = '$PATH/apexcharts.amd.js';

  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js';

  static final String JS_WRAPPER_GLOBAL_NAME =
      '__ChartEngine_Wrapper_ApexCharts__';

  static final LoadController _loadController =
      LoadController('ChartEngineApexCharts');

  @override
  bool get isLoaded =>
      _loadController.isLoaded && _loadController.loadSuccessful;

  @override
  EventStream<LoadController> get onLoad => _loadController.onLoad;

  static JsObject _jsWrapper;

  /// Loads ApexCharts (`apexcharts.amd.js`) and engine wrapper.
  @override
  Future<bool> load() {
    return _loadController.load(() async {
      var okJS = await AMDJS.require('ApexCharts', JS_PATH,
          globalJSVariableName: 'ApexCharts');
      var okWrapper = await AMDJS.require(
          JS_WRAPPER_GLOBAL_NAME, ENGINE_WRAPPER_PATH,
          globalJSVariableName: JS_WRAPPER_GLOBAL_NAME);

      _jsWrapper = context[JS_WRAPPER_GLOBAL_NAME] as JsObject;

      return okJS && okWrapper;
    });
  }

  /// Ensures that DOM element to render is a div. If not will insert a div
  /// inside the element and use it.
  DivElement asDivElement(Element element) {
    if (element == null) {
      throw ArgumentError('Expected a DOM element, but was null!');
    }

    if (element is DivElement) return element;

    var div = DivElement();
    element.children.add(div);

    return div;
  }

  @override
  bool renderLineChart(Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSeries.colors;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      JsObject.jsify(series),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines
    ];

    _jsWrapper.callMethod('renderLine', renderArgs);

    return true;
  }

  @override
  bool renderTimeSeriesChart(Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    var timeSeries = chartSeries.seriesPairsAsList(
        series: series, mapDateTimeToMillis: true);

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSeries.colors;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(timeSeries),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines
    ];

    _jsWrapper.callMethod('renderTimeSeries', renderArgs);

    return true;
  }

  @override
  bool renderBarChart(Element output, ChartSeries chartData) {
    return _renderBarChartImpl(false, output, chartData);
  }

  @override
  bool renderHorizontalBarChart(Element output, ChartSeries chartData) {
    return _renderBarChartImpl(true, output, chartData);
  }

  bool _renderBarChartImpl(
      bool horizontal, Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var set = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSeries.colors;

    var renderArgs = [
      horizontal,
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      JsObject.jsify(set),
      JsObject.jsify(colors),
    ];

    _jsWrapper.callMethod('renderBar', renderArgs);

    return true;
  }

  @override
  bool renderGaugeChart(Element output, ChartSet chartSet) {
    checkRenderParameters(output, chartSet);
    checkLoaded();

    var div = asDivElement(output);

    var set =
        chartSet.options.sortCategories ? chartSet.setSorted : chartSet.set;

    chartSet.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSet.colors;

    var renderArgs = [
      div,
      chartSet.title,
      chartSet.xTitle,
      chartSet.yTitle,
      JsObject.jsify(chartSet.xLabels),
      JsObject.jsify(set),
      JsObject.jsify(colors),
    ];

    _jsWrapper.callMethod('renderGauge', renderArgs);

    return true;
  }

  @override
  bool renderScatterChart(Element output, ChartSeriesPair chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    var seriesPairs = chartSeries.seriesPairsAsList(series: series);

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSeries.colors;

    var yAxisScale = chartSeries.yAxisScale;

    var yMin = yAxisScale.minimumNice;
    var yMax = yAxisScale.maximumNice;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(seriesPairs),
      JsObject.jsify(colors),
      yMin,
      yMax
    ];

    _jsWrapper.callMethod('renderScatter', renderArgs);

    return true;
  }

  @override
  bool renderScatterTimedChart(Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var div = asDivElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    var timeSeries = chartSeries.seriesPairsAsList(
        series: series, mapDateTimeToMillis: true);

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR);

    var colors = chartSeries.colors;

    var yAxisScale = chartSeries.yAxisScale;

    var yMin = yAxisScale.minimumNice;
    var yMax = yAxisScale.maximumNice;

    var renderArgs = [
      div,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(timeSeries),
      JsObject.jsify(colors),
      yMin,
      yMax,
      true
    ];

    _jsWrapper.callMethod('renderScatter', renderArgs);

    return true;
  }
}
