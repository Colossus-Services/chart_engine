import 'dart:html';
import 'dart:js';

import 'package:amdjs/amdjs.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';
import 'chart_engine_date.dart';
import 'chart_engine_series.dart';

/// ChartJS (v2.9.3) Engine.
///
/// Automatically loads `chart.js` using `AMDJS`.
class ChartEngineChartJS extends ChartEngine {
  static final String VERSION = '2.9.3';

  static final String PATH = CHART_ENGINE_PACKAGE_PATH + '/chartjs-$VERSION';

  static final String JS_PATH = '$PATH/Chart.js';

  static final String JS_PATH_MIN = '$PATH/Chart.min.js';

  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js';

  static final String JS_WRAPPER_GLOBAL_NAME =
      '__ChartEngine_Wrapper_ChartJS__';

  static bool _minified = true;

  static bool get minified => _minified;

  /// If true uses minified version of JS files. Should be set before call [load] method.
  static set minified(bool value) {
    _minified = value ?? false;
  }

  static final LoadController _loadController =
      LoadController('ChartEngineChartJS');

  @override
  bool get isLoaded =>
      _loadController.isLoaded && _loadController.loadSuccessful;

  @override
  EventStream<LoadController> get onLoad => _loadController.onLoad;

  static JsObject _jsWrapper;

  /// Loads ChartJS (`chart.js`) and engine wrapper.
  @override
  Future<bool> load() {
    return _loadController.load(() async {
      var jsFullPath = minified ? JS_PATH_MIN : JS_PATH;
      var okJS = await AMDJS.require('chartjs',
          jsFullPath: jsFullPath, globalJSVariableName: 'Chart');
      var okWrapper = await AMDJS.require(JS_WRAPPER_GLOBAL_NAME,
          jsFullPath: ENGINE_WRAPPER_PATH,
          globalJSVariableName: JS_WRAPPER_GLOBAL_NAME);

      _jsWrapper = context[JS_WRAPPER_GLOBAL_NAME] as JsObject;

      _allowInterop();

      return okJS && okWrapper;
    });
  }

  static void _allowInterop() {
    if (_jsWrapper == null) {
      throw StateError("Can't allowInterop _DateAdapter: null _jsWrapper");
    }

    _jsWrapper['_DateAdapter__parse'] = ([a, b]) => DateAdapter.parse(a, b);
    _jsWrapper['_DateAdapter__format'] = ([a, b]) => DateAdapter.format(a, b);
    _jsWrapper['_DateAdapter__startOf'] =
        ([a, b, c]) => DateAdapter.startOf(a, b, c);
    _jsWrapper['_DateAdapter__endOf'] = ([a, b]) => DateAdapter.endOf(a, b);
    _jsWrapper['_DateAdapter__add'] = ([a, b, c]) => DateAdapter.add(a, b, c);
    _jsWrapper['_DateAdapter__diff'] = ([a, b, c]) => DateAdapter.diff(a, b, c);
    _jsWrapper['_DateAdapter__create'] = ([a]) => DateAdapter.create(a);
  }

  ChartEngineChartJS() {
    Future.microtask(load);
  }

  /// Ensures that DOM element to render is a canvas. If not will insert a canvas
  /// inside the element and use it.
  CanvasElement asCanvasElement(Element element) {
    if (element == null) {
      throw ArgumentError('Expected a DOM element, but was null!');
    }

    if (element is CanvasElement) return element;

    var canvas = CanvasElement(width: 640, height: 480);
    element.children.add(canvas);

    return canvas;
  }

  @override
  bool renderLineChart(Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      JsObject.jsify(series),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines,
      chartSeries.options.steppedLines
    ];

    _jsWrapper.callMethod('renderLine', renderArgs);

    return true;
  }

  @override
  bool renderTimeSeriesChart(Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var timeSeries = chartSeries.seriesAsPairsOfMap(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(timeSeries),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines,
      chartSeries.options.steppedLines
    ];

    _jsWrapper.callMethod('renderTimeSeries', renderArgs);

    return true;
  }

  @override
  bool renderBarChart(Element output, ChartSeries chartSeries) {
    return _renderBarChartImpl(false, output, chartSeries);
  }

  @override
  bool renderHorizontalBarChart(Element output, ChartSeries chartSeries) {
    return _renderBarChartImpl(true, output, chartSeries);
  }

  bool _renderBarChartImpl(
      bool horizontal, Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors;

    var renderArgs = [
      horizontal,
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      JsObject.jsify(series),
      JsObject.jsify(colors),
    ];

    _jsWrapper.callMethod('renderBar', renderArgs);

    return true;
  }

  @override
  bool renderGaugeChart(Element output, ChartSet chartSet) {
    checkRenderParameters(output, chartSet);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var set =
        chartSet.options.sortCategories ? chartSet.setSorted : chartSet.set;

    chartSet.ensureColors(colorGenerator);

    var colors = chartSet.colors;
    var disabledColors = chartSet.disabledColors;

    var renderArgs = [
      canvas,
      chartSet.title,
      chartSet.xTitle,
      chartSet.yTitle,
      JsObject.jsify(chartSet.xLabels),
      JsObject.jsify(set),
      JsObject.jsify(colors),
      JsObject.jsify(disabledColors),
    ];

    _jsWrapper.callMethod('renderGauge', renderArgs);

    return true;
  }

  @override
  bool renderScatterChart(Element output, ChartSeriesPair chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var seriesPairs = chartSeries.seriesAsPairsOfMap(
        sortSeriesByCategory: chartSeries.options.sortCategories);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(seriesPairs),
      JsObject.jsify(colors)
    ];

    _jsWrapper.callMethod('renderScatter', renderArgs);

    return true;
  }

  @override
  bool renderScatterTimedChart(Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var seriesPairs = chartSeries.seriesAsPairsOfMap(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(seriesPairs),
      JsObject.jsify(colors),
      true
    ];

    _jsWrapper.callMethod('renderScatter', renderArgs);

    return true;
  }
}
