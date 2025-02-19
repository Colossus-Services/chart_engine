import 'dart:js_interop_unsafe';

import 'package:amdjs/amdjs.dart';
import 'package:dom_tools/dom_tools.dart';
import 'package:swiss_knife/swiss_knife.dart';
import 'package:web_utils/web_utils.dart';

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

  static JSObject? _jsWrapper;

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

      _jsWrapper = globalContext[JS_WRAPPER_GLOBAL_NAME] as JSObject?;

      _allowInterop();

      return okJS && okWrapper;
    });
  }

  static void _allowInterop() {
    if (_jsWrapper == null) {
      throw StateError("Can't allowInterop _DateAdapter: null _jsWrapper");
    }

    _jsWrapper!['_DateAdapter__parse'] =
        (([a, b]) => DateAdapter.parse(a, b)).toJS;
    _jsWrapper!['_DateAdapter__format'] =
        (([a, b]) => DateAdapter.format(a, b)).toJS;
    _jsWrapper!['_DateAdapter__startOf'] =
        (([a, b, c]) => DateAdapter.startOf(a, b, c)).toJS;
    _jsWrapper!['_DateAdapter__endOf'] =
        (([a, b]) => DateAdapter.endOf(a, b)).toJS;
    _jsWrapper!['_DateAdapter__add'] =
        (([a, b, c]) => DateAdapter.add(a, b, c)).toJS;
    _jsWrapper!['_DateAdapter__diff'] =
        (([a, b, c]) => DateAdapter.diff(a, b, c)).toJS;
    _jsWrapper!['_DateAdapter__create'] = (([a]) => DateAdapter.create(a)).toJS;
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
  HTMLCanvasElement asCanvasElement(HTMLElement element) {
    if (element.isA<HTMLCanvasElement>()) return element as HTMLCanvasElement;

    var w = getElementWidth(element, 640) ?? 640;
    var h = getElementHeight(element, 480) ?? 480;

    var canvas = HTMLCanvasElement()
      ..width = w
      ..height = h;

    element.appendChild(canvas);

    return canvas;
  }

  static JSArray? _xAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.xAxisMinMax;
    return minMax?.toJS;
  }

  static JSArray? _yAxisMinMax(ChartData chartData) {
    var minMax = chartData.options.yAxisMinMax;
    return minMax?.toJS;
  }

  static Function? _onClick(ChartData chartData) {
    var onClick = chartData.options.onClick;
    if (onClick == null) return null;
    return (Object? activeItems, Object? xItems, Object? yItems) {
      onClick(
        activeItems.objectDartify() as List?,
        xItems.objectDartify() as List?,
        yItems.objectDartify() as List?,
      );
    };
  }

  static JSObject? _verticalLinesConfig(ChartData chartData) {
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

      return verticalLinesConfig.toJSDeep;
    }

    return null;
  }

  @override
  RenderedChartJS renderLineChart(HTMLElement output, ChartSeries chartData) {
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
      chartData.xLabels.toJSDeep,
      _xAxisMinMax(chartData),
      _yAxisMinMax(chartData),
      series.toJSDeep,
      _verticalLinesConfig(chartData),
      colors.toJSDeep,
      chartData.options.fillLines,
      chartData.options.straightLines,
      chartData.options.steppedLines,
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderLine'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(this, 'line', chartObject, chartData);
  }

  @override
  RenderedChartJS renderTimeSeriesChart(
      HTMLElement output, ChartTimeSeries chartData) {
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
      timeSeries.toJSDeep,
      _verticalLinesConfig(chartData),
      colors.toJSDeep,
      chartData.options.fillLines,
      chartData.options.straightLines,
      chartData.options.steppedLines,
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderTimeSeries'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(this, 'time-series', chartObject, chartData);
  }

  @override
  RenderedChartJS renderBarChart(HTMLElement output, ChartSeries chartData) {
    return _renderBarChartImpl(false, output, chartData);
  }

  @override
  RenderedChartJS renderHorizontalBarChart(
      HTMLElement output, ChartSeries chartData) {
    return _renderBarChartImpl(true, output, chartData);
  }

  RenderedChartJS _renderBarChartImpl(
      bool horizontal, HTMLElement output, ChartSeries chartSeries) {
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
      chartSeries.xLabels.toJSDeep,
      _xAxisMinMax(chartSeries),
      _yAxisMinMax(chartSeries),
      series.toJSDeep,
      colors.toJSDeep,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderBar'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(
        this,
        'bar-${horizontal ? 'horizontal' : 'vertical'}',
        chartObject,
        chartSeries);
  }

  @override
  RenderedChartJS renderGaugeChart(HTMLElement output, ChartSet chartData) {
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
      chartData.xLabels.toJSDeep,
      set.toJSDeep,
      colors.toJSDeep,
      disabledColors.toJSDeep,
      _onClick(chartData)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderGauge'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(this, 'gauge', chartObject, chartData);
  }

  @override
  RenderedChartJS renderScatterChart(
      HTMLElement output, ChartSeriesPair chartSeries) {
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
      seriesPairs.toJSDeep,
      _verticalLinesConfig(chartSeries),
      colors.toJSDeep,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderScatter'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(this, 'scatter', chartObject, chartSeries);
  }

  @override
  RenderedChartJS renderScatterTimedChart(
      HTMLElement output, ChartTimeSeries chartSeries) {
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
      seriesPairs.toJSDeep,
      _verticalLinesConfig(chartSeries),
      colors.toJSDeep,
      true,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderScatter'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(
        this, 'scatter-time-series', chartObject, chartSeries);
  }

  /// Renders financial chart.
  ///
  /// [ohlc] Renders a OHLC chart (default).
  /// [candlestick] Renders a Candlestick chart.
  @override
  RenderedChartJS renderFinancialChart(
      HTMLElement output, ChartTimeSeries chartSeries,
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
      seriesPairs.toJSDeep,
      _verticalLinesConfig(chartSeries),
      colors.toJSDeep,
      colorsUp.toJSDeep,
      colorsDown.toJSDeep,
      colorsUnchanged.toJSDeep,
      ohlc,
      _onClick(chartSeries)
    ];

    var chartObject = _jsWrapper!.callMethodVarArgs<JSObject>(
        'renderFinancial'.toJS, renderArgs.map((e) => e.toJSDeep).toList());

    return RenderedChartJS(this, 'financial-${ohlc ? 'ohlc' : 'candlestick'}',
        chartObject, chartSeries);
  }
}

class RenderedChartJS extends RenderedChart {
  RenderedChartJS(super.engine, super.type, super.chartObject, super.chartData);

  @override
  void refresh() {
    if (!hasChartJSObject) return;
    chartJSObject!.callMethod<JSAny?>('update'.toJS);
  }

  void addDateValue(dynamic date, dynamic value) {
    var dateTime = parseDateTime(date)!;

    var args = <Object?>[
      chartObject,
      dateTime.millisecondsSinceEpoch,
      0,
      value
    ];

    ChartEngineChartJS._jsWrapper!.callMethodVarArgs<JSAny?>(
        'addData_date_value'.toJS, args.map((e) => e.toJSDeep).toList());
  }

  void addOHLC(dynamic series, dynamic time, double open, double high,
      double lower, double close,
      {int? timeTolerance, preserveTimeOfOverwrittenValue}) {
    var dateTime = parseDateTime(time)!;

    preserveTimeOfOverwrittenValue ??= false;

    var args = <Object?>[
      chartObject,
      series,
      {
        't': dateTime.millisecondsSinceEpoch,
        'o': open,
        'h': high,
        'l': lower,
        'c': close
      }.toJSDeep,
      timeTolerance,
      preserveTimeOfOverwrittenValue
    ];

    ChartEngineChartJS._jsWrapper!.callMethodVarArgs<JSAny?>(
        'addData_tohlc'.toJS, args.map((e) => e.toJSDeep).toList());
  }

  void addData(dynamic xVal, dynamic yVal) {}
}
