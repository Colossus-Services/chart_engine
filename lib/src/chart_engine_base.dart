import 'dart:html';

import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_series.dart';

/// The browser path for package resources.
final String CHART_ENGINE_PACKAGE_PATH = 'packages/chart_engine';

/// Abstract Chart Engine definition.
abstract class ChartEngine {
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
      throw StateError(
          'Trying to render before load() engine[${runtimeType}]!');
    }
  }

  /// Renders at [output] a [chartData], selecting the correct render method.
  bool render(Element output, ChartData chartData) {
    if (chartData == null) return false;

    checkLoaded();

    if (chartData is ChartSeries) {
      return renderLineChart(output, chartData);
    } else if (chartData is ChartSet) {
      return renderBarChart(output, chartData);
    }

    return false;
  }

  /// Renders a Line Chart:
  bool renderLineChart(Element output, ChartSeries chartSeries);

  /// Renders a Bar Chart:
  bool renderBarChart(Element output, ChartSet chartSet);
}

/// A ChartEngine wrapper with switchable internal engines:
class ChartEngineSwitchable extends ChartEngine {
  final Set<ChartEngine> engines;

  ChartEngine _mainEngine;

  ChartEngineSwitchable(this.engines,
      {Type mainEngineType, ChartEngine mainEngine}) {
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
  ChartEngine get mainEngine => _mainEngine;

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

  bool renderWithType(Type engineType, Element output, ChartData chartData) {
    var prevMainEngine = _mainEngine;
    setMainEngineByType(engineType);
    var ok = render(output, chartData);
    _mainEngine = prevMainEngine;
    return ok;
  }

  bool renderOfType<T>(Element output, ChartData chartData) {
    var prevMainEngine = _mainEngine;
    setMainEngineOfType<T>();
    var ok = render(output, chartData);
    _mainEngine = prevMainEngine;
    return ok;
  }

  @override
  bool renderBarChart(Element output, ChartSet chartData) {
    return mainEngine.renderBarChart(output, chartData);
  }

  @override
  bool renderLineChart(Element output, ChartSeries chartData) {
    return mainEngine.renderLineChart(output, chartData);
  }
}
