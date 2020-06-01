import 'dart:collection';

import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_colors.dart';

void _sorteEntriesByKey(List<MapEntry> entries) {
  entries.sort( (a,b) {
    var c1 = a.key as Comparable ;
    var c2 = b.key as Comparable ;
    return c1.compareTo(c2) ;
  } );
}

/// Abstract Chart Data.
abstract class ChartData<C,X,Y> {
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

  Iterable<X> get xAxisAllValues ;
  Iterable<Y> get yAxisAllValues ;

  Scale<X> _xAxisScale ;

  Scale<X> get xAxisScale {
    if (_xAxisScale == null) {
      var values = xAxisAllValues ;
      _xAxisScale = isNumList(values) ?
        ScaleNum<num>.from( values.cast() ) :
        Scale.from(values)
      ;
    }

    return _xAxisScale ;
  }

  Scale<Y> _yAxisScale ;

  Scale<Y> get yAxisScale {
    if (_yAxisScale == null) {
      var values = yAxisAllValues ;
      _yAxisScale = isNumList(values) ?
        ScaleNum<num>.from( values.cast() ) :
        Scale.from(values)
      ;
    }

    return _yAxisScale ;
  }

}

/// Data Series, usually for Line Charts.
class ChartSeries<C,X,Y,P> extends ChartData<C,X,Y> {
  ChartSeriesOptions _options;

  final Map<C, List<P>> series;

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

  Map<C, List<P>> get seriesSortedByCategory {
    var l = series.entries.toList();
    _sorteEntriesByKey(l);
    return Map.fromEntries(l).cast();
  }

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView( xLabels ) ;

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView( series.values.where((e) => e != null).expand((l) => l).cast<Y>() );

}

/// Pair Series, for Scatter or Timed Charts. Each entry should be a pair P of values X and Y.
class ChartSeriesPair<C,X,Y,P> extends ChartSeries<C,X,Y,P> {

  /// Default X keys in Map.
  static const List<String> _defaultXKeys = ['x', 'a', 'time', 't', 'date', 'key', 'k'] ;
  /// Default Y keys in Map.
  static const List<String> _defaultYKeys = ['y', 'b', 'value', 'val', 'v'] ;

  List<String> _xKeys ;

  List<String> get xKeys {
    _xKeys ??= List.from(_defaultXKeys) ;
    return _xKeys;
  }

  /// Possible X keys in Map.
  set xKeys(List<String> value) {
    _xKeys = value ;
  }

  List<String> _yKeys ;

  /// Possible Y keys in Map.
  List<String> get yKeys {
    _yKeys ??= _defaultYKeys ;
    return _yKeys;
  }

  set yKeys(List<String> value) {
    _yKeys = value;
  }

  ChartSeriesPair(Map<C, List<P>> series) : super([], series);

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView( series.values.where((e) => e != null).expand((e) => e).map(getPairX) ) ;

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView( series.values.where((e) => e != null).expand((e) => e).map(getPairY) ) ;

  /// Copies this series swapping the XY pairs.
  ChartSeriesPair<C,Y,X,dynamic> swapXY() {
    var seriesSwapped = series.map((key, value) => MapEntry(key, swapListOfPairs(value) ) ) ;

    var  copy = ChartSeriesPair<C,Y,X,dynamic>( seriesSwapped );

    copy.xTitle = yTitle ;
    copy.yTitle = xTitle ;
    copy.title = title ;
    copy.colors = colors ;
    copy.disabledColors = disabledColors ;
    copy._options = _options.copy() ;

    return copy ;
  }

  X getPairX(P pair) {
    if (pair == null) {
      return null ;
    }
    else if (pair is List) {
      return pair[0] ;
    }
    else if (pair is Map) {
      return findKeyValue(pair as Map<String,dynamic>, xKeys, true) ;
    }
    else if (pair is Pair) {
      return pair.a ;
    }
    else if (pair is String) {
      return pair.split(stringPairDelimiterPattern)[0] as X ;
    }
    else {
      throw UnsupportedError("Can't handle pair of type ${ pair.runtimeType }: $pair") ;
    }
  }

  Y getPairY(P pair) {
    if (pair == null) {
      return null ;
    }
    else if (pair is List) {
      return pair[1] ;
    }
    else if (pair is Map) {
      return findKeyValue(pair as Map<String,dynamic>, yKeys, true) ;
    }
    else if (pair is Pair) {
      return pair.b ;
    }
    else if (pair is String) {
      return pair.split(stringPairDelimiterPattern)[1] as Y ;
    }
    else {
      throw UnsupportedError("Can't handle pair of type ${ pair.runtimeType }: $pair") ;
    }
  }

  List swapListOfPairs(List<P> list) {
    return list.map((p) => swapPair(p)).toList() ;
  }

  /// Swaps a Pair XY.
  dynamic swapPair(dynamic pair) {
    if (pair == null) {
      return null ;
    }
    else if (pair is List) {
      return swapPairAsList(pair);
    }
    else if (pair is Map) {
      return swapPairAsMap(pair);
    }
    else if (pair is Pair) {
      return swapPairAsPair(pair);
    }
    else if (pair is String) {
      return swapPairAsString(pair);
    }
    else {
      throw UnsupportedError("Can't swap pair of type ${ pair.runtimeType }: $pair") ;
    }
  }

  /// Swaps a Pair when is a [List].
  List swapPairAsList(List pair) {
    return [ pair[1] , pair[0] ] ;
  }

  /// Swaps a Pair when is a [Map].
  Map swapPairAsMap(Map pair) {
    var x = findKeyEntry(pair, xKeys) ;
    var y = findKeyEntry(pair, yKeys) ;
    return { x.key : y.value , y.key : x.value } ;
  }

  /// Swaps a Pair when is of type [Pair].
  Pair swapPairAsPair(Pair pair) {
    return pair.swapAB() ;
  }

  static final RegExp DEFAULT_STRING_PAIR_DELIMITER_PATTERN = RegExp(r'\s*[,;:\|]\s*');

  RegExp _stringPairDelimiterPattern = DEFAULT_STRING_PAIR_DELIMITER_PATTERN ;

  RegExp get stringPairDelimiterPattern => _stringPairDelimiterPattern;
  set stringPairDelimiterPattern(RegExp value) {
    _stringPairDelimiterPattern = value ?? DEFAULT_STRING_PAIR_DELIMITER_PATTERN ;
  }

  /// Swaps a Pair when is a [String].
  String swapPairAsString(String pair) {
    var parts = <String>[] ;
    var delimiter = '' ;

    pair.splitMapJoin( stringPairDelimiterPattern ,
        onMatch: (m) {
          delimiter = m.group(0);
          return '';
        } ,
        onNonMatch: (s) {
          parts.add(s);
          return '' ;
        }
    ) ;

    while (parts.length < 2) {
      parts.add('') ;
    }

    var swap = '${ parts[1] }$delimiter${ parts[0] }';

    return swap ;
  }

  /// Used to normalize series for engines that requires a pair as List[a,b].
  Map<C, List<List<dynamic>>> seriesPairsAsList( [Map<C, List<P>> series] ) {
    series ??= this.series ;
    return series.map((key, value) => MapEntry(key, toListOfPairsAsList(value) ) ) ;
  }

  /// Used to normalize series for engines that requires a pair as Map{x,y}.
  Map<C, List<Map<String,dynamic>>> seriesPairsAsMap( [Map<C, List<P>> series] ) {
    series ??= this.series ;
    return series.map((key, value) => MapEntry(key, toListOfPairsAsMap(value) ) ) ;
  }

  List<List<dynamic>> toListOfPairsAsList(List<P> listOfPairs) {
    return listOfPairs.map( toPairAsList ).toList() ;
  }

  List<Map<String,dynamic>> toListOfPairsAsMap(List<P> listOfPairs) {
    return listOfPairs.map( toPairAsMap ).toList().cast() ;
  }

  List<dynamic> toPairAsList(P pair) {
    return toPair(pair , (X x, Y y) => [x,y] ) ;
  }

  Map<String,dynamic> toPairAsMap(P pair) {
    return toPair(pair , (X x, Y y) => {'x': x , 'y': y } ) ;
  }

  R toPair<R>(dynamic pair, R Function(X date, Y value) typeWrapper) {
    if (pair == null) return null;

    var a;
    var b;

    if (pair is List) {
      a = pair[0];
      b = pair[1];
    }
    else if (pair is Map) {
      a = findKeyValue(pair, ['x', 'a', 'time', 't', 'date', 'key', 'k'], true);
      b = findKeyValue(pair, ['y', 'b', 'value', 'val', 'v'], true);
    }
    else if (pair is Pair) {
      a = pair.a;
      b = pair.b;
    }
    else if (pair is String) {

      var split = pair.split(stringPairDelimiterPattern);
      a = split[0].trim();
      b = split[1].trim();
    }
    else {
      return null;
    }

    return toPairImpl(a, b, typeWrapper) ;
  }

  /// Actual implementation of pair values.
  R toPairImpl<R>(dynamic a, dynamic b, R Function(X x, Y y) typeWrapper) {
    return typeWrapper(a,b) ;
  }

}

/// Time Series, for Time Series Charts. Each entry should be a pair of DateTime and Value.
class ChartTimeSeries<C,Y,P> extends ChartSeriesPair<C,DateTime,Y,P> {

  ChartTimeSeries(Map<C, List<P>> series) : super(series);

  @override
  R toPairImpl<R>(dynamic a, dynamic b, R Function(DateTime date, Y value) typeWrapper) {
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

    return typeWrapper(date, v) ;
  }

}

/// Data Set, usually for Gauge and Pie Charts.
class ChartSet<X, Y> extends ChartData<X,X,Y> {
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
    _sorteEntriesByKey(l);
    return Map.fromEntries(l).cast();
  }

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView( set.keys ) ;

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView( set.values ) ;

}


abstract class ChartOptions {
  /// Sort Categories/Series.keys when showing them in the Chart.
  bool _sortCategories = false;

  bool get sortCategories => _sortCategories;

  set sortCategories(bool value) {
    _sortCategories = value ?? false;
  }

  ChartOptions copy() ;
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

  @override
  ChartSeriesOptions copy() {
    var copy = ChartSeriesOptions() ;

    copy._straightLines = _straightLines ;
    copy._fillLines = _fillLines ;
    copy._sortCategories = _sortCategories ;

    return copy ;
  }
}

/// Possible options for Set Charts.
class ChartSetOptions extends ChartOptions {

  @override
  ChartSetOptions copy() {
    var copy = ChartSetOptions() ;
    return copy ;
  }

}
