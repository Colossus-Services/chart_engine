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

  /// Colors of each category when disabled.
  Map<C, String> disabledColors;

  /// The categories (usually X axis) of the Chart.
  List<C> get categories;

  /// Same as [categories], but as String.
  List<String> get categoriesAsStrings => categories.map((e) => '$e').toList();

  /// Set the Colors Map using a [colorGenerator].
  void setColors(ColorGenerator colorGenerator) {
    colors = colorGenerator.buildColors(List.from(categories).cast());
    disabledColors = colorGenerator.buildDisabledColors(List.from(categories).cast());
  }

  /// Ensure that the Colors Map is set, using a [colorGenerator].
  void ensureColors(ColorGenerator colorGenerator) {
    colors ??= colorGenerator.buildColors(List.from(categories).cast());
    disabledColors ??= colorGenerator.buildDisabledColors(List.from(categories).cast());
  }

}

void _sorteEntries(List<MapEntry> entries) {
  entries.sort( (a,b) {
    var c1 = a.key as Comparable ;
    var c2 = b.key as Comparable ;
    return c1.compareTo(c2) ;
  } );
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
    _sorteEntries(l);
    return Map.fromEntries(l).cast();
  }

}


/// Time Series, for Time Series Charts. Each entry should be a pair of DateTime and Value.
class ChartTimeSeries<C> extends ChartSeries<DateTime,C,List> {

  ChartTimeSeries(Map<C, List<List>> series) : super([], series);

  /// Used to normalize series for engines that requires a pair as Map{x: DateTime, y: Value}.
  Map<C, List<Map>> seriesWithPairMap( [Map<C, List<List>> series] ) {
    series ??= series ;
    return series.map((key, value) => MapEntry(key, toTimeSeriesListOfPairMap(value) ) ) ;
  }

  /// Used to normalize series for engines that requires a pair as List[DateTime, value].
  Map<C, List<List>> seriesWithPairList( [Map<C, List<List>> series] ) {
    series ??= series ;
    return series.map((key, value) => MapEntry(key, toTimeSeriesListOfPairList(value) ) ) ;
  }

  static List toTimeSeriesListOfPairList(List<List> listOfPairs) {
    return listOfPairs.map( _toTimeSeriesPairList ).toList() ;
  }

  static List toTimeSeriesListOfPairMap(List<List> listOfPairs) {
    return listOfPairs.map( _toTimeSeriesPairMap ).toList() ;
  }

  static Map _toTimeSeriesPairMap(List pair) {
    return _toTimeSeriesPairImpl(pair , (DateTime d, dynamic v) => {'x': d.millisecondsSinceEpoch , 'y': v } ) ;
  }

  static List _toTimeSeriesPairList(List pair) {
    return _toTimeSeriesPairImpl(pair , (DateTime d, dynamic v) => [ d.millisecondsSinceEpoch , v ] ) ;
  }

  static R _toTimeSeriesPairImpl<R>(List pair, R Function(DateTime date, dynamic value) consumer ) {
    var a = pair[0] ;
    var b = pair[1] ;

    DateTime date ;
    var v ;

    if ( a is DateTime ) {
      date = a ;
      v = b ;
    }
    else if ( b is DateTime ) {
      date = b ;
      v = a ;
    }
    else if ( a is int && b is int ) {
      if ( a > b ) {
        date = DateTime.fromMillisecondsSinceEpoch(a) ;
        v = b ;
      }
      else {
        date = DateTime.fromMillisecondsSinceEpoch(b) ;
        v = a ;
      }
    }
    else if ( a is String ){
      date = DateTime.parse(a) ;
      v = b ;
    }
    else if ( b is String ){
      date = DateTime.parse(b) ;
      v = b ;
    }

    return consumer(date, v) ;
  }

}

/// Data Set, usually for Gauge and Pie Charts.
class ChartSet<X, Y> extends ChartData<X> {
  ChartSetOptions _options;

  Map<X, Y> set;

  List<X> get xLabels => categories ;

  ChartSet(this.set, {ChartSetOptions options})
      : _options = options ?? ChartSetOptions();

  /// The options for set data: [ChartSetOptions]
  ChartSetOptions get options => _options;

  set options(ChartSetOptions value) {
    _options = value ?? ChartSetOptions();
  }

  @override
  List<X> get categories => set.keys.toList().cast();

  Map<X, Y> get setSorted {
    var l = set.entries.toList();
    _sorteEntries(l);
    return Map.fromEntries(l).cast();
  }

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
