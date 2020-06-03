import 'dart:collection';

import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_colors.dart';

void _sorteEntriesByKey(List<MapEntry> entries) {
  entries.sort((a, b) {
    var c1 = a.key as Comparable;
    var c2 = b.key as Comparable;
    return c1.compareTo(c2);
  });
}

/// Abstract Chart Data.
abstract class ChartData<C, X, Y> {

  /// Returns [true] if [value] is a UNIX epoch integer.
  ///
  /// [inMilliseconds] consider epoch in milliseconds.
  static bool isValueInUnixEpochRange(int value, [bool inMilliseconds]) {
    inMilliseconds ??= true ;

    if (inMilliseconds) {
      return value > 946692000000 && value < 32503690800000 ;
    }
    else {
      return value > 946692000 && value < 32503690800 ;
    }
  }

  /// Returns [true] if [value] is a UNIX epoch [int] or a [DateTime].
  static bool isTimeValue(dynamic value) {
    return ( value is int && isValueInUnixEpochRange(value) ) || value is DateTime ;
  }

  /// Returns [true] if [value] is a valid value for the charts.
  static bool isValidValue(dynamic value) {
    return value is num || isTimeValue(value) ;
  }

  /// Returns [true] if [list] is a [List] of paris.
  static bool isListOfPairs(Iterable list) {
    if (list == null || list.isEmpty) return null ;
    return listMatchesAll(list, (e) => e is List && e.length == 2 && listMatchesAll(e, isValidValue)) ;
  }

  /// Returns [true] if [list] is a [List] of time pairs (X: DateTime, Y: value).
  static bool isListOfTimedPairs(Iterable list) {
    if (list == null || list.isEmpty) return null ;
    return listMatchesAll(list, (e) => e is List && e.length == 2 && isTimeValue(e[0]) && e[1] is num ) ;
  }

  /// Returns [true] if [list] elements are valid values.
  static bool isListOfValidValues(Iterable list) {
    if (list == null || list.isEmpty) return null ;
    return listMatchesAll(list, (e) => e is List && listMatchesAll(e, isValidValue)) ;
  }

  /// Returns [true] if [map] is valid for [ChartSet].
  static bool matchesSet(Map map) {
    return listMatchesAll(map.values, (e) => e is num) ;
  }

  /// Returns [true] if [map] is valid for [ChartSeries].
  static bool matchesSeries(Map map) {
    return listMatchesAll(map.values, (values) => isListOfValidValues(values) ) ;
  }

  /// Returns [true] if [map] is valid for [ChartTimeSeries].
  static bool matchesTimeSeries(Map map) {
    return listMatchesAll(map.values, (values) => isListOfTimedPairs(values) ) ;
  }

  /// Returns [true] if [map] is valid for [ChartSeriesPair].
  static bool matchesSeriesPair(Map map) {
    return listMatchesAll(map.values, (values) => isListOfPairs(values) ) ;
  }

  /// Returns [true] if [map] is valid for a [ChartData] implementation.
  static bool matchesChartData(Map map) {
    return matchesSet(map) || matchesSeries(map) || matchesSeriesPair(map) || matchesTimeSeries(map) ;
  }

  static ChartData from(Map map) {
    if ( matchesSet(map) ) {
      return ChartSet(map) ;
    }
    else if ( matchesTimeSeries(map) ) {
      return ChartTimeSeries(map) ;
    }
    else if ( matchesSeriesPair(map) ) {
      return ChartSeriesPair(map) ;
    }
    else if ( matchesSeries(map) ) {
      return ChartSeries([],map) ;
    }
    else {
      return null;
    }
  }

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
    disabledColors =
        colorGenerator.buildDisabledColors(List.from(categories).cast());
  }

  /// Ensure that the Colors Map is set, using a [colorGenerator].
  void ensureColors(ColorGenerator colorGenerator) {
    colors ??= colorGenerator.buildColors(List.from(categories).cast());
    disabledColors ??=
        colorGenerator.buildDisabledColors(List.from(categories).cast());
  }

  Iterable<X> get xAxisAllValues;

  Iterable<Y> get yAxisAllValues;

  Scale<X> _xAxisScale;

  Scale<X> get xAxisScale {
    if (_xAxisScale == null) {
      var values = xAxisAllValues;
      _xAxisScale = isNumList(values)
          ? ScaleNum<num>.from(values.cast())
          : Scale.from(values);
    }

    return _xAxisScale;
  }

  Scale<Y> _yAxisScale;

  Scale<Y> get yAxisScale {
    if (_yAxisScale == null) {
      var values = yAxisAllValues;
      _yAxisScale = isNumList(values)
          ? ScaleNum<num>.from(values.cast())
          : Scale.from(values);
    }

    return _yAxisScale;
  }

  bool get isEmpty ;
  bool get isNotEmpty => !isEmpty ;

}

/// Data Series, usually for Line Charts.
class ChartSeries<C, X, Y, P> extends ChartData<C, X, Y> {
  ChartSeriesOptions _options;

  final Map<C, List<P>> series;

  final List<X> xLabels;

  ChartSeries(this.xLabels, this.series, {ChartSeriesOptions options})
      : _options = options ?? ChartSeriesOptions();

  @override
  bool get isEmpty => series.isEmpty ;

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
  Iterable<X> get xAxisAllValues => UnmodifiableListView(xLabels);

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView(
      series.values.where((e) => e != null).expand((l) => l).cast<Y>());
}

typedef PairMapper<R, X, Y> = R Function(X x, Y y);
typedef TypeMapper<R, T> = R Function(T o);

/// Pair Series, for Scatter or Timed Charts. Each entry should be a pair P of values X and Y.
class ChartSeriesPair<C, X, Y, P> extends ChartSeries<C, X, Y, P> {
  /// Default X keys in Map.
  static const List<String> _defaultXKeys = [
    'x',
    'a',
    'time',
    't',
    'date',
    'key',
    'k'
  ];

  /// Default Y keys in Map.
  static const List<String> _defaultYKeys = ['y', 'b', 'value', 'val', 'v'];

  List<String> _xKeys;

  List<String> get xKeys {
    _xKeys ??= List.from(_defaultXKeys);
    return _xKeys;
  }

  /// Possible X keys in Map.
  set xKeys(List<String> value) {
    _xKeys = value;
  }

  List<String> _yKeys;

  /// Possible Y keys in Map.
  List<String> get yKeys {
    _yKeys ??= _defaultYKeys;
    return _yKeys;
  }

  set yKeys(List<String> value) {
    _yKeys = value;
  }

  ChartSeriesPair(Map<C, List<P>> series) : super([], series);

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView(
      series.values.where((e) => e != null).expand((e) => e).map(getPairX));

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView(
      series.values.where((e) => e != null).expand((e) => e).map(getPairY));

  /// Copies this series swapping the XY pairs.
  ChartSeriesPair<C, Y, X, dynamic> swapXY() {
    var seriesSwapped =
        series.map((key, value) => MapEntry(key, swapListOfPairs(value)));

    var copy = ChartSeriesPair<C, Y, X, dynamic>(seriesSwapped);

    copy.xTitle = yTitle;
    copy.yTitle = xTitle;
    copy.title = title;
    copy.colors = colors;
    copy.disabledColors = disabledColors;
    copy._options = _options.copy();

    return copy;
  }

  X getPairX(P pair) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      return pair[0];
    } else if (pair is Map) {
      return findKeyValue(pair as Map<String, dynamic>, xKeys, true);
    } else if (pair is Pair) {
      return pair.a;
    } else if (pair is String) {
      return pair.split(stringPairDelimiterPattern)[0] as X;
    } else {
      throw UnsupportedError(
          "Can't handle pair of type ${pair.runtimeType}: $pair");
    }
  }

  Y getPairY(P pair) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      return pair[1];
    } else if (pair is Map) {
      return findKeyValue(pair as Map<String, dynamic>, yKeys, true);
    } else if (pair is Pair) {
      return pair.b;
    } else if (pair is String) {
      return pair.split(stringPairDelimiterPattern)[1] as Y;
    } else {
      throw UnsupportedError(
          "Can't handle pair of type ${pair.runtimeType}: $pair");
    }
  }

  void getPairXY(P pair, List returnXY) {
    if (pair == null) {
      return;
    } else if (pair is List) {
      returnXY[0] = pair[0];
      returnXY[1] = pair[1];
      return;
    } else if (pair is Map) {
      var keyX = findKeyName(pair as Map<String, dynamic>, xKeys, true);
      var keyY = findKeyName(pair as Map<String, dynamic>, yKeys, true);
      returnXY[0] = pair[keyX];
      returnXY[1] = pair[keyY];
      return;
    } else if (pair is Pair) {
      returnXY[0] = pair.a;
      returnXY[1] = pair.b;
      return;
    } else if (pair is String) {
      var parts = pair.split(stringPairDelimiterPattern);
      returnXY[0] = parts[0];
      returnXY[1] = parts[1];
      return;
    } else {
      throw UnsupportedError(
          "Can't handle pair of type ${pair.runtimeType}: $pair");
    }
  }

  P setPairXY(P pair, X x, Y y) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      if ( x.runtimeType == y.runtimeType ) {
        pair[0] = x;
        pair[1] = y;
        return null ;
      }
      else {
        return [x,y] as P ;
      }
    } else if (pair is Map) {
      var keyX = findKeyName(pair as Map<String, dynamic>, xKeys, true);
      var keyY = findKeyName(pair as Map<String, dynamic>, yKeys, true);
      pair[keyX] = x;
      pair[keyY] = y;
      return null;
    } else if (pair is Pair) {
      return Pair(x, y) as P;
    } else if (pair is String) {
      String s = pair;

      var delimiter = '';

      s.splitMapJoin(stringPairDelimiterPattern,
          onNonMatch: (p) => '',
          onMatch: (m) {
            delimiter = m[0];
            return '';
          });

      return '$x$delimiter$y' as P;
    } else {
      throw UnsupportedError(
          "Can't handle pair of type ${pair.runtimeType}: $pair");
    }
  }

  List swapListOfPairs(List<P> list) {
    return list.map((p) => swapPair(p)).toList();
  }

  /// Swaps a Pair XY.
  dynamic swapPair(dynamic pair) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      return swapPairAsList(pair);
    } else if (pair is Map) {
      return swapPairAsMap(pair);
    } else if (pair is Pair) {
      return swapPairAsPair(pair);
    } else if (pair is String) {
      return swapPairAsString(pair);
    } else {
      throw UnsupportedError(
          "Can't swap pair of type ${pair.runtimeType}: $pair");
    }
  }

  /// Swaps a Pair when is a [List].
  List swapPairAsList(List pair) {
    return [pair[1], pair[0]];
  }

  /// Swaps a Pair when is a [Map].
  Map swapPairAsMap(Map pair) {
    var x = findKeyEntry(pair, xKeys);
    var y = findKeyEntry(pair, yKeys);
    return {x.key: y.value, y.key: x.value};
  }

  /// Swaps a Pair when is of type [Pair].
  Pair swapPairAsPair(Pair pair) {
    return pair.swapAB();
  }

  static final RegExp DEFAULT_STRING_PAIR_DELIMITER_PATTERN =
      RegExp(r'\s*[,;:\|]\s*');

  RegExp _stringPairDelimiterPattern = DEFAULT_STRING_PAIR_DELIMITER_PATTERN;

  RegExp get stringPairDelimiterPattern => _stringPairDelimiterPattern;

  set stringPairDelimiterPattern(RegExp value) {
    _stringPairDelimiterPattern =
        value ?? DEFAULT_STRING_PAIR_DELIMITER_PATTERN;
  }

  /// Swaps a Pair when is a [String].
  String swapPairAsString(String pair) {
    var parts = <String>[];
    var delimiter = '';

    pair.splitMapJoin(stringPairDelimiterPattern, onMatch: (m) {
      delimiter = m.group(0);
      return '';
    }, onNonMatch: (s) {
      parts.add(s);
      return '';
    });

    while (parts.length < 2) {
      parts.add('');
    }

    var swap = '${parts[1]}$delimiter${parts[0]}';

    return swap;
  }

  /// Used to normalize series for engines that requires a pair as List[a,b].
  Map<C, List<List<dynamic>>> seriesPairsAsList(
      {Map<C, List<P>> series,
      TypeMapper xMapper,
      TypeMapper yMapper,
      bool mapDateTimeToMillis = false}) {
    series ??= this.series;
    mapDateTimeToMillis ??= false;

    if (mapDateTimeToMillis) {
      xMapper ??= (o) => o is DateTime ? o.millisecondsSinceEpoch : o;
      yMapper ??= (o) => o is DateTime ? o.millisecondsSinceEpoch : o;
    }

    return series.map((key, value) => MapEntry(
        key, toListOfPairsAsList(value, xMapper: xMapper, yMapper: yMapper)));
  }

  /// Used to normalize series for engines that requires a pair as Map{x,y}.
  Map<C, List<Map<String, dynamic>>> seriesPairsAsMap(
      {Map<C, List<P>> series,
      TypeMapper xMapper,
      TypeMapper yMapper,
      bool mapDateTimeToMillis = false}) {
    series ??= this.series;
    mapDateTimeToMillis ??= false;

    if (mapDateTimeToMillis) {
      xMapper ??= (o) => o is DateTime ? o.millisecondsSinceEpoch : o;
      yMapper ??= (o) => o is DateTime ? o.millisecondsSinceEpoch : o;
    }

    return series.map((key, value) => MapEntry(
        key, toListOfPairsAsMap(value, xMapper: xMapper, yMapper: yMapper)));
  }

  List<List<dynamic>> toListOfPairsAsList(List<P> listOfPairs,
      {TypeMapper xMapper, TypeMapper yMapper}) {
    return listOfPairs
        .map((e) => toPairAsList(e, xMapper: xMapper, yMapper: yMapper))
        .toList();
  }

  List<Map<String, dynamic>> toListOfPairsAsMap(List<P> listOfPairs,
      {TypeMapper xMapper, TypeMapper yMapper}) {
    return listOfPairs
        .map((e) => toPairAsMap(e, xMapper: xMapper, yMapper: yMapper))
        .toList()
        .cast();
  }

  List<dynamic> toPairAsList(P pair, {TypeMapper xMapper, TypeMapper yMapper}) {
    if (xMapper == null && yMapper == null) {
      return toPair(pair, (X x, Y y) => [x, y]);
    } else {
      xMapper ??= (o) => o;
      yMapper ??= (o) => o;
      return toPair(pair, (X x, Y y) => [xMapper(x), yMapper(y)]);
    }
  }

  Map<String, dynamic> toPairAsMap(P pair,
      {TypeMapper xMapper, TypeMapper yMapper}) {
    if (xMapper == null && yMapper == null) {
      return toPair(pair, (X x, Y y) => {'x': x, 'y': y});
    } else {
      xMapper ??= (o) => o;
      yMapper ??= (o) => o;
      return toPair(pair, (X x, Y y) => {'x': xMapper(x), 'y': yMapper(y)});
    }
  }

  R toPair<R>(dynamic pair, PairMapper<R, X, Y> typeWrapper) {
    if (pair == null) return null;

    var a;
    var b;

    if (pair is List) {
      a = pair[0];
      b = pair[1];
    } else if (pair is Map) {
      a = findKeyValue(pair, ['x', 'a', 'time', 't', 'date', 'key', 'k'], true);
      b = findKeyValue(pair, ['y', 'b', 'value', 'val', 'v'], true);
    } else if (pair is Pair) {
      a = pair.a;
      b = pair.b;
    } else if (pair is String) {
      var split = pair.split(stringPairDelimiterPattern);
      a = split[0].trim();
      b = split[1].trim();
    } else {
      return null;
    }

    return toPairImpl(a, b, typeWrapper);
  }

  /// Actual implementation of pair values.
  R toPairImpl<R>(dynamic a, dynamic b, PairMapper<R, X, Y> typeWrapper) {
    return typeWrapper(a, b);
  }
}

/// Time Series, for Time Series Charts. Each entry should be a pair of DateTime and Value.
class ChartTimeSeries<C, Y> extends ChartSeriesPair<C, DateTime, Y, dynamic> {
  ChartTimeSeries(Map<C, List<dynamic>> series) : super( series.map((key, value) => MapEntry<C,List>(key, value)) ) {
    _normalizePairs();
  }

  /// Normalizes all pairs to ensure DateTime at X axis.
  /// (Called by the constructor)
  void _normalizePairs() {
    var returnXY = <dynamic>[null, null];

    var keys = List.from(series.keys) ;

    for (var key in keys) {
      var values = List<dynamic>.from( series[key] ) ;
      series[key] = values ;

      var length = values.length;

      for (var i = 0; i < length; i++) {
        var pair = values[i];

        getPairXY(pair, returnXY);

        dynamic x = returnXY[0];
        dynamic y = returnXY[1];

        var modified = false;

        if (x is String && isInt(x)) {
          x = parseInt(x);
          modified = true;
        }

        if (y is String && isInt(y)) {
          y = parseInt(y);
          modified = true;
        }

        DateTime date;
        var val;

        if (x is DateTime) {
          if (!modified) continue;

          date = x;
          val = y;
        } else if (y is DateTime) {
          date = y;
          val = x;
        } else if ( (x is int && y is num) || (x is num && y is int) ) {
          if (x > y) {
            date = DateTime.fromMillisecondsSinceEpoch(x);
            val = y;
          } else {
            val = x;
            date = DateTime.fromMillisecondsSinceEpoch(y);
          }
        } else if (x is String) {
          date = DateTime.parse(x);
          val = y;
        } else if (y is String) {
          val = x;
          date = DateTime.parse(y);
        }

        if (date != null && val != null) {
          var pair2 = setPairXY(pair, date, val);
          if (pair2 != null) {
            values[i] = pair2;
          }
        }
      }

      if ( !ChartData.isListOfTimedPairs(values) ) {
        ChartData.isListOfTimedPairs(values);
        throw StateError("Can't normalize timed pairs");
      }
    }




  }

}

/// Data Set, usually for Gauge and Pie Charts.
class ChartSet<X, Y> extends ChartData<X, X, Y> {
  ChartSetOptions _options;

  Map<X, Y> set;

  List<X> get xLabels => categories;

  ChartSet(this.set, {ChartSetOptions options})
      : _options = options ?? ChartSetOptions();

  @override
  bool get isEmpty => set.isEmpty ;

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
  Iterable<X> get xAxisAllValues => UnmodifiableListView(set.keys);

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView(set.values);

  ChartSeries get asChartSeries {
    return ChartSeries([], set.map((key, value) => MapEntry(key, [value])) ) ;
  }

}

abstract class ChartOptions {
  /// Sort Categories/Series.keys when showing them in the Chart.
  bool _sortCategories = false;

  bool get sortCategories => _sortCategories;

  set sortCategories(bool value) {
    _sortCategories = value ?? false;
  }

  ChartOptions copy();
}

/// Possible options for Series Charts.
class ChartSeriesOptions extends ChartOptions {

  /// Draw stepped lines.
  bool _steppedLines = false;

  bool get steppedLines => _steppedLines;

  set steppedLines(bool value) {
    _steppedLines = value ?? false ;
  }

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
    var copy = ChartSeriesOptions();

    copy._straightLines = _straightLines;
    copy._fillLines = _fillLines;
    copy._sortCategories = _sortCategories;

    return copy;
  }
}

/// Possible options for Set Charts.
class ChartSetOptions extends ChartOptions {
  @override
  ChartSetOptions copy() {
    var copy = ChartSetOptions();
    return copy;
  }
}
