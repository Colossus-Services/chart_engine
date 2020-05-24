import 'chart_engine_colors.dart';

/// Abstract Chart Data.
abstract class ChartData<C> {
  /// The title of the Chart.
  String title;

  /// Title of X axis. If null it won't be rendered.
  String xTitle;

  /// Title of Y axis. If null it won't be rendered.
  String yTitle;

  /// Colors of each category.
  Map<C, String> colors;

  /// The categories (usually X axis) of the Chart.
  List<C> get categories;

  /// Same as [categories], but as String.
  List<String> get categoriesAsStrings => categories.map((e) => '$e').toList();

  /// Set the Colors Map using a [colorGenerator].
  void setColors(ColorGenerator colorGenerator) {
    colors = colorGenerator.buildColors(List.from(categories).cast());
  }

  /// Ensure that the Colors Map is set, using a [colorGenerator].
  void ensureColors(ColorGenerator colorGenerator) {
    colors ??= colorGenerator.buildColors(List.from(categories).cast());
  }
}

/// Data Series, usually for Line Charts.
class ChartSeries<X, C, Y> extends ChartData<C> {
  ChartSeriesOptions _options;

  final Map<C, List<Y>> series;

  final List<X> xLabels;

  ChartSeries(this.xLabels, this.series, {ChartSeriesOptions options})
      : _options = options ?? ChartSeriesOptions();

  /// The options for series data: [ChartSeriesOptions]
  ChartSeriesOptions get options => _options;

  set options(ChartSeriesOptions value) {
    _options = value ?? ChartSeriesOptions();
  }

  @override
  List<C> get categories => series.keys.toList().cast();

  Map<C, List<Y>> get seriesSorted {
    var l = series.entries.toList();
    l.sort();
    return Map.fromEntries(l).cast();
  }
}

/// Data Set, usually for Bar Charts.
class ChartSet<X, C, Y> extends ChartData<C> {
  ChartSetOptions _options;

  Map<C, Y> set;

  List<X> xLabels;

  ChartSet(this.xLabels, this.set, {ChartSetOptions options})
      : _options = options ?? ChartSetOptions();

  /// The options for set data: [ChartSetOptions]
  ChartSetOptions get options => _options;

  set options(ChartSetOptions value) {
    _options = value ?? ChartSetOptions();
  }

  @override
  List<C> get categories => set.keys.toList().cast();
}

abstract class ChartOptions {
  /// Sort Categories/Series.keys when showing them in the Chart.
  bool _sortCategories = false;

  bool get sortCategories => _sortCategories;

  set sortCategories(bool value) {
    _sortCategories = value ?? false;
  }
}

/// Possible options for Series Charts.
class ChartSeriesOptions extends ChartOptions {
  /// Draw straight lines instead of smooth lines.
  bool _straightLines = false;

  bool get straightLines => _straightLines;

  set straightLines(bool value) {
    _straightLines = value ?? false;
  }

  /// Draw lines area, filling the area beneath them.
  bool _fillLines = false;

  bool get fillLines => _fillLines;

  set fillLines(bool value) {
    _fillLines = value ?? false;
  }
}

/// Possible options for Set Charts.
class ChartSetOptions extends ChartOptions {}
