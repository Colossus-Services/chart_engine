
import 'dart:html';
import 'dart:js';

import 'package:amdjs/amdjs.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';
import 'chart_engine_series.dart';
import 'chart_engine_colors.dart';


/// ApexCharts (v3.19.0) Engine.
///
/// Automatically loads `apexcharts.js` using `AMDJS`.
class ChartEngineApexCharts extends ChartEngine {

  static final String VERSION = '3.19.0' ;
  static final String PATH = CHART_ENGINE_PACKAGE_PATH + '/apexcharts-$VERSION' ;
  static final String JS_PATH = '$PATH/apexcharts.amd.js' ;
  static final String ENGINE_WRAPPER_PATH = '$PATH/chart_engine_wrapper.js' ;
  static final String JS_WRAPPER_GLOBAL_NAME = '__ChartEngine_Wrapper_ApexCharts__' ;

  static final LoadController _loadController = LoadController('ChartEngineApexCharts') ;

  @override
  bool get isLoaded => _loadController.isLoaded && _loadController.loadSuccessful ;

  @override
  EventStream<LoadController> get onLoad => _loadController.onLoad ;

  JsObject _jsWrapper ;

  /// Loads ApexCharts (`apexcharts.amd.js`) and egine wrapper.
  @override
  Future<bool> load() {
    return _loadController.load( () async {
      var okJS = await AMDJS.require('ApexCharts', JS_PATH, globalJSVariableName: 'ApexCharts') ;
      var okWrapper = await AMDJS.require(JS_WRAPPER_GLOBAL_NAME, ENGINE_WRAPPER_PATH, globalJSVariableName: JS_WRAPPER_GLOBAL_NAME) ;

      _jsWrapper = context[JS_WRAPPER_GLOBAL_NAME] as JsObject;

      return okJS && okWrapper ;
    });
  }

  /// Ensures that DOM element to render is a div. If not will insert a div
  /// inside the element and use it.
  DivElement asDivElement(Element element) {
    if (element == null) throw ArgumentError('Expected a DOM element, but was null!') ;

    if (element is DivElement) return element ;

    var div = DivElement() ;
    element.children.add(div) ;

    return div ;
  }

  @override
  bool renderLineChart(Element output, ChartSeries  chartSeries) {
    checkLoaded();

    var div = asDivElement(output) ;

    var series = chartSeries.options.sortCategories ? chartSeries.seriesSorted : chartSeries.series ;

    chartSeries.ensureColors(STANDARD_COLOR_GENERATOR) ;

    var colors = chartSeries.colors ;

    var renderArgs = [
      div,
      chartSeries.title, chartSeries.xTitle, chartSeries.yTitle,
      JsObject.jsify(chartSeries.xLabels) ,
      JsObject.jsify(series),
      JsObject.jsify(colors),
      chartSeries.options.fillLines,
      chartSeries.options.straightLines
    ];


    _jsWrapper.callMethod('renderLine' , renderArgs) ;

    return true ;
  }

  @override
  bool renderBarChart(Element output, ChartSet chartSet) {
    checkLoaded();
    throw UnimplementedError();
  }

}
