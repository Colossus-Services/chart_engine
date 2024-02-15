import 'dart:html';
import 'dart:js';

import 'package:amdjs/amdjs.dart';
import 'package:dom_tools/dom_tools.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';
import 'chart_engine_date.dart';
import 'chart_engine_series.dart';

/// ChartJS (v2.9.4) Engine.
///
/// Automatically loads `chart.js` using `AMDJS`.
class ChartEngineChartJS extends ChartEngine {
  // ignore: non_constant_identifier_names
  static final String VERSION = '2.9.4';

  // ignore: non_constant_identifier_names
  static final String PATH = '$CHART_ENGINE_PACKAGE_PATH/chartjs-$VERSION';

  // ignore: non_constant_identifier_names
  static final String JS_PATH = '$PATH/Chart.js';

  // ignore: non_constant_identifier_names
  static final String JS_PATH_MIN = '$PATH/Chart.min.js';

  // ignore: non_constant_identifier_names
  static final String FINANCIAL_JS_PATH =
      '$PATH/financial/chartjs-chart-financial.js';

  // ignore: non_constant_identifier_names
  static final String FINANCIAL_JS_PATH_MIN =
      '$PATH/financial/chartjs-chart-financial.min.js';

  // ignore: non_constant_identifier_names
  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js';

  // ignore: non_constant_identifier_names
  static final String JS_WRAPPER_GLOBAL_NAME =
      '__ChartEngine_Wrapper_ChartJS__';

  /// If true uses minified version of JS files. Should be set before call [load] method.
  static bool minified = true;

  @override
  String get version => VERSION;

  static final LoadController _loadController =
      LoadController('ChartEngineChartJS');

  @override
  bool get isLoaded =>
      _loadController.isLoaded && _loadController.loadSuccessful!;

  @override
  EventStream<LoadController> get onLoad => _loadController.onLoad;

  static JsObject? _jsWrapper;

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

      _jsWrapper = context[JS_WRAPPER_GLOBAL_NAME] as JsObject?;

      _allowInterop();

      return okJS && okWrapper;
    });
  }

  static void _allowInterop() {
    if (_jsWrapper == null) {
      throw StateError("Can't allowInterop _DateAdapter: null _jsWrapper");
    }

    _jsWrapper!['_DateAdapter__parse'] = ([a, b]) => DateAdapter.parse(a, b);
    _jsWrapper!['_DateAdapter__format'] = ([a, b]) => DateAdapter.format(a, b);
    _jsWrapper!['_DateAdapter__startOf'] =
        ([a, b, c]) => DateAdapter.startOf(a, b, c);
    _jsWrapper!['_DateAdapter__endOf'] = ([a, b]) => DateAdapter.endOf(a, b);
    _jsWrapper!['_DateAdapter__add'] = ([a, b, c]) => DateAdapter.add(a, b, c);
    _jsWrapper!['_DateAdapter__diff'] =
        ([a, b, c]) => DateAdapter.diff(a, b, c);
    _jsWrapper!['_DateAdapter__create'] = ([a]) => DateAdapter.create(a);
  }

  static final LoadController _loadControllerFinancial =
      LoadController('ChartEngineChartJS:financial');

  /// Returns [true] if financial module is loaded.
  bool get isLoadedFinancial =>
      _loadControllerFinancial.isLoaded &&
      _loadControllerFinancial.loadSuccessful!;

  void checkLoadedFinancial() {
    checkLoaded();

    if (!isLoadedFinancial) {
      throw StateError(
          'Trying to render before loadFinancial() of engine[$runtimeType]!');
    }
  }

  /// Loads ChartJS Financial module.
  Future<bool> loadFinancial() {
    return _loadControllerFinancial.load(() async {
      var okChartJS = await load();
      if (!okChartJS) return false;

      var jsFullPath = minified ? FINANCIAL_JS_PATH_MIN : FINANCIAL_JS_PATH;
      var okJS = await AMDJS.require('chartjs_financial',
          jsFullPath: jsFullPath, globalJSVariableName: 'Chart.Financial');

      return okChartJS && okJS;
    });
  }

  ChartEngineChartJS() {
    Future.microtask(load);
  }

  /// Ensures that DOM element to render is a canvas. If not will insert a canvas
  /// inside the element and use it.
  CanvasElement asCanvasElement(Element element) {
    if (element is CanvasElement) return element;

    var w = getElementWidth(element, 640);
    var h = getElementHeight(element, 480);

    var canvas = CanvasElement(width: w, height: h);
    element.children.add(canvas);

    return canvas;
  }

  static JsObject? _xAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.xAxisMinMax;
    return minMax != null ? JsObject.jsify(minMax) : null;
  }

  static JsObject? _yAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.yAxisMinMax;
    return minMax != null ? JsObject.jsify(minMax) : null;
  }

  static Function? _onClick(ChartData chartData) {
    var onClick = chartData.options.onClick;
    if (onClick == null) return null;
    return (activeItems, xItems, yItems) {
      onClick(
          jsToDart(activeItems) as List<dynamic>?,
          jsToDart(xItems) as List<dynamic>?,
          jsToDart(yItems) as List<dynamic>?);
    };
  }

  static JsObject? _verticalLinesConfig(ChartData chartData) {
    var lines = chartData.options.verticalLines;

    if (isNotEmptyObject(lines)) {
      var defColor = chartData.options.verticalLinesDefaultColor;

      var verticalLinesConfig = <int, Map<String, dynamic>>{};

      for (var i = 0; i < lines!.length; i++) {
        var line = lines[i];
        var idx = line.index;
        var label = line.label ?? '';
        var color = line.color ?? defColor;
        var yPos = line.yPosition ?? 1.0;
        var textAlign = line.textAlign ?? 'center';

        verticalLinesConfig[idx] = {
          'label': label,
          'color': color,
          'y': yPos,
          'textAlign': textAlign
        };
      }

      return JsObject.jsify(verticalLinesConfig);
    }

    return null;
  }

  @override
  RenderedChartJS renderLineChart(Element output, ChartSeries chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var series = chartData.options.sortCategories
        ? chartData.seriesSortedByCategory
        : chartData.series;

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;

    var renderArgs = [
      canvas,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      JsObject.jsify(chartData.xLabels),
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      JsObject.jsify(series),
      _verticalLinesConfig(chartData),
      JsObject.jsify(colors),
      chartData.options.fillLines,
      chartData.options.straightLines,
      chartData.options.steppedLines,
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethod('renderLine', renderArgs);

    return RenderedChartJS(this, 'line', chartObject, chartData);
  }

  @override
  RenderedChartJS renderTimeSeriesChart(
      Element output, ChartTimeSeries chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var timeSeries = chartData.seriesAsPairsOfMap(
        sortSeriesByCategory: chartData.options.sortCategories,
        mapDateTimeToMillis: true);

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;

    var renderArgs = [
      canvas,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      JsObject.jsify(timeSeries),
      _verticalLinesConfig(chartData),
      JsObject.jsify(colors),
      chartData.options.fillLines,
      chartData.options.straightLines,
      chartData.options.steppedLines,
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethod('renderTimeSeries', renderArgs);

    return RenderedChartJS(this, 'time-series', chartObject, chartData);
  }

  @override
  RenderedChartJS renderBarChart(Element output, ChartSeries chartData) {
    return _renderBarChartImpl(false, output, chartData);
  }

  @override
  RenderedChartJS renderHorizontalBarChart(
      Element output, ChartSeries chartData) {
    return _renderBarChartImpl(true, output, chartData);
  }

  RenderedChartJS _renderBarChartImpl(
      bool horizontal, Element output, ChartSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var series = chartSeries.options.sortCategories
        ? chartSeries.seriesSortedByCategory
        : chartSeries.series;

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      horizontal,
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels),
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(series),
      JsObject.jsify(colors),
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethod('renderBar', renderArgs);

    return RenderedChartJS(
        this,
        'bar-${horizontal ? 'horizontal' : 'vertical'}',
        chartObject,
        chartSeries);
  }

  @override
  RenderedChartJS renderGaugeChart(Element output, ChartSet chartData) {
    checkRenderParameters(output, chartData);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var set =
        chartData.options.sortCategories ? chartData.setSorted : chartData.set;

    chartData.ensureColors(colorGenerator);

    var colors = chartData.colors!;
    var disabledColors = chartData.disabledColors!;

    var renderArgs = [
      canvas,
      chartData.title,
      chartData.xTitle,
      chartData.yTitle,
      JsObject.jsify(chartData.xLabels),
      JsObject.jsify(set),
      JsObject.jsify(colors),
      JsObject.jsify(disabledColors),
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethod('renderGauge', renderArgs);

    return RenderedChartJS(this, 'gauge', chartObject, chartData);
  }

  @override
  RenderedChartJS renderScatterChart(
      Element output, ChartSeriesPair chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var seriesPairs = chartSeries.seriesAsPairsOfMap(
        sortSeriesByCategory: chartSeries.options.sortCategories);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(seriesPairs),
      _verticalLinesConfig(chartSeries),
      JsObject.jsify(colors),
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethod('renderScatter', renderArgs);

    return RenderedChartJS(this, 'scatter', chartObject, chartSeries);
  }

  @override
  RenderedChartJS renderScatterTimedChart(
      Element output, ChartTimeSeries chartSeries) {
    checkRenderParameters(output, chartSeries);
    checkLoaded();

    var canvas = asCanvasElement(output);

    var seriesPairs = chartSeries.seriesAsPairsOfMap(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(seriesPairs),
      _verticalLinesConfig(chartSeries),
      JsObject.jsify(colors),
      true,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethod('renderScatter', renderArgs);

    return RenderedChartJS(
        this, 'scatter-time-series', chartObject, chartSeries);
  }

  /// Renders financial chart.
  ///
  /// [ohlc] Renders a OHLC chart (default).
  /// [candlestick] Renders a Candlestick chart.
  @override
  RenderedChartJS renderFinancialChart(
      Element output, ChartTimeSeries chartSeries,
      {bool? ohlc, bool? candlestick}) {
    checkRenderParameters(output, chartSeries);
    checkLoadedFinancial();

    candlestick ??= false;
    ohlc ??= !candlestick;

    if (ohlc && candlestick) {
      print(
          'renderFinancialChart> Conflicting parameters: ohlc = $ohlc ; candlestick = $candlestick! Will use ohlc as primary.');
    }

    var canvas = asCanvasElement(output);

    var seriesPairs = chartSeries.seriesAsEntriesOfTOHLC(
        sortSeriesByCategory: chartSeries.options.sortCategories,
        mapDateTimeToMillis: true);

    chartSeries.ensureColors(colorGenerator);

    var colors = chartSeries.colors!;
    var colorsUp = chartSeries.colorsLighter;
    var colorsDown = chartSeries.colorsDarker;
    var colorsUnchanged = chartSeries.disabledColors!;

    var renderArgs = [
      canvas,
      chartSeries.title,
      chartSeries.xTitle,
      chartSeries.yTitle,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      JsObject.jsify(seriesPairs),
      _verticalLinesConfig(chartSeries),
      JsObject.jsify(colors),
      JsObject.jsify(colorsUp),
      JsObject.jsify(colorsDown),
      JsObject.jsify(colorsUnchanged),
      ohlc,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethod('renderFinancial', renderArgs);

    return RenderedChartJS(this, 'financial-${ohlc ? 'ohlc' : 'candlestick'}',
        chartObject, chartSeries);
  }
}

class RenderedChartJS extends RenderedChart {
  RenderedChartJS(super.engine, super.type, super.chartObject, super.chartData);

  @override
  void refresh() {
    if (!hasChartJsObject) return;
    chartJsObject!.callMethod('update');
  }

  void addDateValue(dynamic date, dynamic value) {
    var dateTime = parseDateTime(date)!;

    var args = [chartObject, dateTime.millisecondsSinceEpoch, 0, value];

    ChartEngineChartJS._jsWrapper!.callMethod('addData_date_value', args);
  }

  void addOHLC(dynamic series, dynamic time, double open, double high,
      double lower, double close,
      {int? timeTolerance, preserveTimeOfOverwrittenValue}) {
    var dateTime = parseDateTime(time)!;

    preserveTimeOfOverwrittenValue ??= false;

    var args = [
      chartObject,
      series,
      JsObject.jsify({
        't': dateTime.millisecondsSinceEpoch,
        'o': open,
        'h': high,
        'l': lower,
        'c': close
      }),
      timeTolerance,
      preserveTimeOfOverwrittenValue
    ];

    ChartEngineChartJS._jsWrapper!.callMethod('addData_tohlc', args);
  }

  void addData(dynamic xVal, dynamic yVal) {}
}
