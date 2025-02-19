import 'dart:collection';

import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:swiss_knife/swiss_knife.dart';

import 'chart_engine_base.dart';

void _sorteEntriesByKey<K extends Comparable, V>(List<MapEntry<K, V>> entries) {
  entries.sort((a, b) {
    var c1 = a.key;
    var c2 = b.key;
    return c1.compareTo(c2);
  });
}

/// Abstract Chart Data.
abstract class ChartData<C, X, Y> {
  /// Returns [true] if [value] is a UNIX epoch integer.
  ///
  /// [inMilliseconds] consider epoch in milliseconds.
  static bool isValueInUnixEpochRange(int value, [bool? inMilliseconds]) {
    inMilliseconds ??= true;

    if (inMilliseconds) {
      return value > 946692000000 && value < 32503690800000;
    } else {
      return value > 946692000 && value < 32503690800;
    }
  }

  /// Returns [true] if [value] is a UNIX epoch [int] or a [DateTime].
  static bool isTimeValue(dynamic value) {
    return (value is int && isValueInUnixEpochRange(value)) ||
        value is DateTime;
  }

  /// Returns [true] if [value] is a valid value for the charts.
  static bool isValidValue(dynamic value) {
    return value is num || isTimeValue(value);
  }

  /// Returns [true] if [list] is a [List] of paris.
  static bool isListOfPairs(Iterable list) {
    if (list.isEmpty) return false;
    return listMatchesAll(
        list,
        (dynamic e) =>
            e is List && e.length == 2 && listMatchesAll(e, isValidValue));
  }

  /// Returns [true] if [list] is a [List] of time pairs (X: DateTime, Y: value).
  static bool isListOfTimedPairs(Iterable list) {
    if (list.isEmpty) return false;
    return listMatchesAll(
        list,
        (dynamic e) =>
            e is List && e.length == 2 && isTimeValue(e[0]) && e[1] is num);
  }

  /// Returns [true] if [list] elements are valid values.
  static bool isListOfValidValues(Iterable list) {
    if (list.isEmpty) return false;
    return listMatchesAll(
        list, (dynamic e) => e is List && listMatchesAll(e, isValidValue));
  }

  /// Returns [true] if [map] is valid for [ChartSet].
  static bool matchesSet(Map map) {
    return listMatchesAll(map.values, (dynamic e) => e is num);
  }

  /// Returns [true] if [map] is valid for [ChartSeries].
  static bool matchesSeries(Map map) {
    return listMatchesAll(
        map.values, (dynamic values) => isListOfValidValues(values));
  }

  /// Returns [true] if [map] is valid for [ChartTimeSeries].
  static bool matchesTimeSeries(Map map) {
    return listMatchesAll(
        map.values, (dynamic values) => isListOfTimedPairs(values));
  }

  /// Returns [true] if [map] is valid for [ChartSeriesPair].
  static bool matchesSeriesPair(Map map) {
    return listMatchesAll(
        map.values, (dynamic values) => isListOfPairs(values));
  }

  /// Returns [true] if [map] is valid for a [ChartData] implementation.
  static bool matchesChartData(Map map) {
    return matchesSet(map) ||
        matchesSeries(map) ||
        matchesSeriesPair(map) ||
        matchesTimeSeries(map);
  }

  static ChartData? from(Map map) {
    if (matchesSet(map)) {
      return ChartSet(map);
    } else if (matchesTimeSeries(map)) {
      return ChartTimeSeries(map as Map<dynamic, List<dynamic>>);
    } else if (matchesSeriesPair(map)) {
      return ChartSeriesPair(map as Map<dynamic, List<dynamic>>);
    } else if (matchesSeries(map)) {
      return ChartSeries([], map as Map<dynamic, List<dynamic>>);
    } else {
      return null;
    }
  }

  /// The title of the Chart.
  String? title;

  /// Title of X axis. If null it won't be rendered.
  String? xTitle;

  /// Title of Y axis. If null it won't be rendered.
  String? yTitle;

  /// Colors of each category.
  Map<C, String>? colors;

  /// Lighter colors of each category.
  Map<C, String> get colorsLighter => colors!.map((key, color) {
        var htmlColor = HTMLColor.from(color)!.brighter();
        return MapEntry(key, htmlColor.toString());
      });

  /// Darker colors of each category.
  Map<C, String> get colorsDarker => colors!.map((key, color) {
        var htmlColor = HTMLColor.from(color)!.darker();
        return MapEntry(key, htmlColor.toString());
      });

  /// Colors of each category when disabled.
  Map<C, String>? disabledColors;

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

  /// The options to render this data in the chart.
  ChartOptions get options;

  /// Returns a [X] value at [index].
  X getXAxisValue(int index);

  /// Returns all values of axis X.
  Iterable<X> get xAxisAllValues;

  /// Returns all values of axis Y.
  Iterable<Y> get yAxisAllValues;

  Scale<X>? _xAxisScale;

  /// Returns the [Scale] of axis X.
  Scale<X>? get xAxisScale {
    if (_xAxisScale == null) {
      var values = xAxisAllValues;
      _xAxisScale = isNumList(values)
          ? ScaleNum.from<num>(values.cast<num>()) as Scale<X>?
          : Scale.from(values) as Scale<X>?;
    }

    return _xAxisScale;
  }

  Scale<Y>? _yAxisScale;

  /// Returns the [Scale] of axis Y.
  Scale<Y>? get yAxisScale {
    if (_yAxisScale == null) {
      var values = yAxisAllValues;
      _yAxisScale = isNumList(values)
          ? ScaleNum.from<num>(values.cast<num>()) as Scale<Y>?
          : Scale.from(values) as Scale<Y>?;
    }

    return _yAxisScale;
  }

  /// Returns [true] if this is empty.
  bool get isEmpty;

  /// ![isEmpty]
  bool get isNotEmpty => !isEmpty;

  /// If [true] will populate [lastRenderedChart]
  bool populateLastRenderedChart = false;

  /// Last instance of [RenderedChart] for this [ChartData].
  /// Only populated if [populateLastRenderedChart] is [true].
  RenderedChart? lastRenderedChart;
}

/// Data Series, usually for Line Charts.
class ChartSeries<C, X, Y, P> extends ChartData<C, X, Y> {
  /// The options for series data: [ChartSeriesOptions]
  @override
  ChartSeriesOptions options;

  final Map<C, List<P>> series;

  final List<X> xLabels;

  ChartSeries(this.xLabels, this.series, {ChartSeriesOptions? options})
      : options = options ?? ChartSeriesOptions();

  @override
  bool get isEmpty => series.isEmpty;

  @override
  List<C> get categories => series.keys.toList().cast();

  Map<C, List<P>> get seriesSortedByCategory {
    var l = series.entries.cast<MapEntry<Comparable, dynamic>>().toList();
    _sorteEntriesByKey(l);
    return Map.fromEntries(l).cast();
  }

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView(xLabels);

  @override
  X getXAxisValue(int index) {
    return xLabels[index];
  }

  @override
  Iterable<Y> get yAxisAllValues =>
      UnmodifiableListView(series.values.expand((l) => l).cast<Y>());
}

typedef PairMapper<R, X, Y> = R Function(X x, Y y);
typedef TypeMapper<R, T> = R? Function(T? o);

/// Pair Series, for Scatter or Timed Charts. Each entry should be a pair P of values X and Y.
class ChartSeriesPair<C, X, Y, P> extends ChartSeries<C, X?, Y, P> {
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

  List<String>? _xKeys;

  List<String>? get xKeys {
    _xKeys ??= List.from(_defaultXKeys);
    return _xKeys;
  }

  /// Possible X keys in Map.
  set xKeys(List<String>? value) {
    _xKeys = value;
  }

  List<String>? _yKeys;

  /// Possible Y keys in Map.
  List<String>? get yKeys {
    _yKeys ??= _defaultYKeys;
    return _yKeys;
  }

  set yKeys(List<String>? value) {
    _yKeys = value;
  }

  ChartSeriesPair(Map<C, List<P>> series) : super([], series);

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView(
      series.values.expand((e) => e).map((e) => getPairX(e)).whereType<X>());

  @override
  X? getXAxisValue(int index) {
    var seriesValues =
        series.values.firstWhere((e) => index < e.length, orElse: () => <P>[]);
    var value = seriesValues[index];
    return getPairX(value);
  }

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView(
      series.values.expand((e) => e).map((e) => getPairY(e)).whereType<Y>());

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
    copy.options = options.copy();

    return copy;
  }

  X? getPairX(P pair) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      return pair[0];
    } else if (pair is Map) {
      var val = findKeyValue((pair as Map<String, dynamic>), xKeys, true);
      return val as X?;
    } else if (pair is Pair) {
      return pair.a;
    } else if (pair is String) {
      return pair.split(stringPairDelimiterPattern)[0] as X;
    } else {
      throw UnsupportedError(
          "Can't handle pair of type ${pair.runtimeType}: $pair");
    }
  }

  Y? getPairY(P pair) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      return pair[1];
    } else if (pair is Map) {
      var val = findKeyValue((pair as Map<String, dynamic>), yKeys, true);
      return val as Y?;
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
      var keyY = findKeyName(pair, yKeys, true);
      returnXY[0] = pair[keyX!];
      returnXY[1] = pair[keyY!];
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

  P? setPairXY(P pair, X x, Y y) {
    if (pair == null) {
      return null;
    } else if (pair is List) {
      if (x.runtimeType == y.runtimeType) {
        pair[0] = x;
        pair[1] = y;
        return null;
      } else {
        return [x, y] as P;
      }
    } else if (pair is Map) {
      var keyX = findKeyName(pair as Map<String, dynamic>, xKeys, true)!;
      var keyY = findKeyName(pair, yKeys, true)!;
      pair[keyX] = x;
      pair[keyY] = y;
      return null;
    } else if (pair is Pair) {
      return Pair(x, y) as P;
    } else if (pair is String) {
      String s = pair;

      String? delimiter = '';

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
    var x = findKeyEntry(pair, xKeys)!;
    var y = findKeyEntry(pair, yKeys)!;
    return {x.key: y.value, y.key: x.value};
  }

  /// Swaps a Pair when is of type [Pair].
  Pair swapPairAsPair(Pair pair) {
    return pair.swapAB();
  }

  static final RegExp _defaultStringPairDelimiterPattern =
      RegExp(r'\s*[,;:|]\s*');

  RegExp stringPairDelimiterPattern = _defaultStringPairDelimiterPattern;

  /// Swaps a Pair when is a [String].
  String swapPairAsString(String pair) {
    var parts = <String>[];
    String? delimiter = '';

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

  /// Returns [series] as pairs of [List].
  Map<C, List<List<dynamic>>> seriesAsPairsOfList(
      {bool sortSeriesByCategory = false, bool mapDateTimeToMillis = true}) {
    var series = sortSeriesByCategory ? seriesSortedByCategory : this.series;
    return seriesPairsAsList(
        series: series, mapDateTimeToMillis: mapDateTimeToMillis);
  }

  /// Used to normalize series for engines that requires a pair as List[a,b].
  Map<C, List<List<dynamic>>> seriesPairsAsList(
      {Map<C, List<P>>? series,
      TypeMapper? xMapper,
      TypeMapper? yMapper,
      bool mapDateTimeToMillis = false}) {
    series ??= this.series;

    if (mapDateTimeToMillis) {
      xMapper ??= _mapDateTimeToMillis;
      yMapper ??= _mapDateTimeToMillis;
    }

    return series.map((key, value) => MapEntry(
        key, toListOfPairsAsList(value, xMapper: xMapper, yMapper: yMapper)));
  }

  static dynamic _mapDateTimeToMillis(o) =>
      o is DateTime ? o.millisecondsSinceEpoch : parseInt(o, 0);

  /// Returns [series] as pairs of [Map].
  Map<C, List<Map<String, dynamic>>> seriesAsPairsOfMap(
      {bool sortSeriesByCategory = false, bool mapDateTimeToMillis = true}) {
    var series = sortSeriesByCategory ? seriesSortedByCategory : this.series;
    return seriesPairsAsMap(
        series: series, mapDateTimeToMillis: mapDateTimeToMillis);
  }

  /// Used to normalize series for engines that requires a pair as Map{x,y}.
  Map<C, List<Map<String, dynamic>>> seriesPairsAsMap(
      {Map<C, List<P>>? series,
      TypeMapper? xMapper,
      TypeMapper? yMapper,
      bool mapDateTimeToMillis = false}) {
    series ??= this.series;

    if (mapDateTimeToMillis) {
      xMapper ??= _mapDateTimeToMillis;
      yMapper ??= _mapDateTimeToMillis;
    }

    return series.map((key, value) => MapEntry(
        key, toListOfPairsAsMap(value, xMapper: xMapper, yMapper: yMapper)));
  }

  /// Returns the [DataTime] minimum and maximum value of all series.
  List<DateTime>? allSeriesDateTimeMinMax({bool sortSeriesByCategory = false}) {
    var series = seriesDateTimeMinMax();
    return _datesMinMax(series.values.expand((e) => e).toList());
  }

  /// Returns the [DataTime] minimum and maximum value for each series.
  Map<C, List<DateTime>> seriesDateTimeMinMax(
      {bool sortSeriesByCategory = false}) {
    var seriesDates =
        seriesDateTime(sortSeriesByCategory: sortSeriesByCategory);
    var entries = seriesDates.entries.map((e) {
      var datesMinMax = _datesMinMax(e.value);
      return datesMinMax != null ? MapEntry(e.key, datesMinMax) : null;
    }).whereType<MapEntry<C, List<DateTime>>>();
    return Map<C, List<DateTime>>.fromEntries(entries);
  }

  List<DateTime>? _datesMinMax(List<DateTime> dates) {
    if (dates.isEmpty) return null;

    var datesSorted = List.from(dates);
    datesSorted.sort();

    var min = datesSorted.first;
    var max = datesSorted.last;

    return [min, max];
  }

  /// Returns series [DateTime] values.
  Map<C, List<DateTime>> seriesDateTime({bool sortSeriesByCategory = false}) {
    var series = sortSeriesByCategory ? seriesSortedByCategory : this.series;

    var series2 =
        series.map((key, value) => MapEntry(key, toListOfDateTime(value)));
    return series2;
  }

  List<DateTime> toListOfDateTime(Iterable list) {
    return list.map(_toDateTime).toList().cast();
  }

  DateTime? _toDateTime(dynamic e) {
    if (e is DateTime) {
      return e;
    } else if (e is int && isInUnixEpochRange(e)) {
      return DateTime.fromMillisecondsSinceEpoch(e);
    } else if (e is String) {
      var s = e.trim();
      if (isInt(s)) {
        var n = parseInt(s);
        if (isInUnixEpochRange(n)) {
          return DateTime.fromMillisecondsSinceEpoch(n!);
        }
      } else if (s.length >= 4) {
        try {
          return DateTime.parse(s);
        } catch (e) {
          return null;
        }
      }
    } else if (e is Iterable) {
      for (var v in e) {
        var d = _toDateTime(v);
        if (d != null) return d;
      }
      return null;
    } else if (e is Map) {
      var d = _toDateTime(e.values);
      if (d != null) return d;
      d = _toDateTime(e.keys);
      if (d != null) return d;
    }
    return null;
  }

  /// Returns [series] as entries of TOHLC Maps.
  Map<C, List<Map<String, dynamic>>> seriesAsEntriesOfTOHLC(
      {bool sortSeriesByCategory = false, bool mapDateTimeToMillis = true}) {
    var series = sortSeriesByCategory ? seriesSortedByCategory : this.series;
    return seriesEntriesAsTOHLC(
        series: series, mapDateTimeToMillis: mapDateTimeToMillis);
  }

  Map<C, List<Map<String, dynamic>>> seriesEntriesAsTOHLC(
      {Map<C, List<P>>? series,
      TypeMapper? tMapper,
      TypeMapper? oMapper,
      TypeMapper? hMapper,
      TypeMapper? lMapper,
      TypeMapper? cMapper,
      bool mapDateTimeToMillis = false}) {
    series ??= this.series;

    if (mapDateTimeToMillis) {
      tMapper ??= (e) => _mapDateTimeToMillis(_getObjectValue(e, 0, 't', null));
    }

    var series2 = series.map((key, value) => MapEntry(
        key,
        toListOfTOHLC(value,
            tMapper: tMapper,
            oMapper: oMapper,
            hMapper: hMapper,
            lMapper: lMapper,
            cMapper: cMapper)));

    return series2;
  }

  List<List<dynamic>> toListOfPairsAsList(List<P> listOfPairs,
      {TypeMapper? xMapper, TypeMapper? yMapper}) {
    return listOfPairs
        .map((e) => toPairAsList(e, xMapper: xMapper, yMapper: yMapper))
        .whereType<List<dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> toListOfPairsAsMap(List<P> listOfPairs,
      {TypeMapper? xMapper, TypeMapper? yMapper}) {
    return listOfPairs
        .map((e) => toPairAsMap(e, xMapper: xMapper, yMapper: yMapper))
        .toList()
        .cast();
  }

  List<Map<String, dynamic>> toListOfTOHLC(List<P> listOfPairs,
      {TypeMapper? tMapper,
      TypeMapper? oMapper,
      TypeMapper? hMapper,
      TypeMapper? lMapper,
      TypeMapper? cMapper}) {
    var list = listOfPairs
        .map((e) => {
              't': _getObjectValue(e, 0, 't', tMapper),
              'o': _getObjectValue(e, 1, 'o', oMapper),
              'h': _getObjectValue(e, 2, 'h', hMapper),
              'l': _getObjectValue(e, 3, 'l', lMapper),
              'c': _getObjectValue(e, 4, 'c', cMapper),
            })
        .toList();

    list.sort((a, b) {
      var t1 = _mapDateTimeToMillis(a['t']);
      var t2 = _mapDateTimeToMillis(b['t']);
      return t1 < t2 ? -1 : (t1 == t2 ? 0 : 1);
    });

    return list.cast();
  }

  dynamic _getObjectValue(
      dynamic o, int index, String key, TypeMapper? mapper) {
    if (mapper != null) return mapper(o);
    if (o == null) return null;
    if (o is List) return o[index];
    if (o is Map) return o[key];
    return o;
  }

  List<dynamic>? toPairAsList(P pair,
      {TypeMapper? xMapper, TypeMapper? yMapper}) {
    if (xMapper == null && yMapper == null) {
      return toPair(pair, (X? x, Y? y) => [x, y]);
    } else {
      xMapper ??= (o) => o;
      yMapper ??= (o) => o;
      return toPair(pair, (X? x, Y? y) => [xMapper!(x), yMapper!(y)]);
    }
  }

  Map<String, dynamic>? toPairAsMap(P pair,
      {TypeMapper? xMapper, TypeMapper? yMapper}) {
    if (xMapper == null && yMapper == null) {
      return toPair(pair, (X? x, Y? y) => {'x': x, 'y': y});
    } else {
      xMapper ??= (o) => o;
      yMapper ??= (o) => o;
      return toPair(pair, (X? x, Y? y) => {'x': xMapper!(x), 'y': yMapper!(y)});
    }
  }

  R? toPair<R>(dynamic pair, PairMapper<R, X?, Y?> typeWrapper) {
    if (pair == null) return null;

    dynamic a, b;

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
  R toPairImpl<R>(dynamic a, dynamic b, PairMapper<R, X?, Y?> typeWrapper) {
    return typeWrapper(a, b);
  }
}

/// Time Series, for Time Series Charts. Each entry should be a pair of DateTime and Value.
class ChartTimeSeries<C, Y> extends ChartSeriesPair<C, DateTime, Y, dynamic> {
  ChartTimeSeries(Map<C, List<dynamic>> series)
      : super(series.map((key, value) => MapEntry<C, List>(key, value))) {
    _normalizePairs();
  }

  /// Normalizes all pairs to ensure DateTime at X axis.
  /// (Called by the constructor)
  void _normalizePairs() {
    var returnXY = <dynamic>[null, null];

    var keys = List.from(series.keys);

    for (var key in keys) {
      var values = List<dynamic>.from(series[key]!);
      series[key] = values;

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

        DateTime? date;
        dynamic val;

        if (x is DateTime) {
          if (!modified) continue;

          date = x;
          val = y;
        } else if (y is DateTime) {
          date = y;
          val = x;
        } else if ((x is int && y is num) || (x is num && y is int)) {
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

      _sortValuesPairs(values);
    }
  }

  void _sortValuesPairs(List values) {
    var returnXY1 = <dynamic>[null, null];
    var returnXY2 = <dynamic>[null, null];

    values.sort((p1, p2) {
      getPairXY(p1, returnXY1);
      getPairXY(p2, returnXY2);

      var x1 = returnXY1[0];
      var x2 = returnXY2[0];

      if (x1 is DateTime && x2 is DateTime) {
        return x1.compareTo(x2);
      }

      return 0;
    });
  }
}

/// Data Set, usually for Gauge and Pie Charts.
class ChartSet<X, Y> extends ChartData<X, X, Y> {
  /// The options for set data: [ChartSetOptions]
  @override
  ChartSetOptions options;

  Map<X, Y> set;

  List<X> get xLabels => categories;

  ChartSet(this.set, {ChartSetOptions? options})
      : options = options ?? ChartSetOptions();

  @override
  bool get isEmpty => set.isEmpty;

  @override
  List<X> get categories => set.keys.toList().cast();

  Map<X, Y> get setSorted {
    var l = set.entries.cast<MapEntry<Comparable, dynamic>>().toList();
    _sorteEntriesByKey(l);
    return Map.fromEntries(l).cast();
  }

  @override
  Iterable<X> get xAxisAllValues => UnmodifiableListView(set.keys);

  @override
  X getXAxisValue(int index) {
    var seriesValues = set.keys.toList();
    var value = seriesValues[index];
    return value;
  }

  @override
  Iterable<Y> get yAxisAllValues => UnmodifiableListView(set.values);

  ChartSeries get asChartSeries {
    return ChartSeries([], set.map((key, value) => MapEntry(key, [value])));
  }
}

/// Represents a vertical line in the chart.
class VerticalLine {
  /// The index of the dataset value.
  final int index;

  /// Label for the line.
  final String? label;

  /// Color of lien and label.
  final String? color;

  /// Position (from 0 to 1) in the Y axis.
  final double? yPosition;

  /// The text align with the vertical line: `center`, 'left', 'right'.
  final String? textAlign;

  VerticalLine(this.index,
      {this.label, this.color, this.yPosition, this.textAlign}) {
    if (index < 0) {
      throw ArgumentError('Invalid index: $index');
    }
  }

  @override
  String toString() {
    return 'VerticalLine{index: $index, label: $label, color: $color, yPosition: $yPosition, textAlign: $textAlign}';
  }
}

/// Base class for chart render options.
abstract class ChartOptions {
  /// Sort Categories/Series.keys when showing them in the Chart.
  bool sortCategories = false;

  /// Minimum value for X axis.
  num? xAxisMin;

  /// Maximum value for X axis.
  num? xAxisMax;

  /// Minimum value for Y axis.
  num? yAxisMin;

  /// Maximum value for Y axis.
  num? yAxisMax;

  /// Returns X axis minimum and maximum values.
  List<num>? get xAxisMinMax =>
      xAxisMin != null || xAxisMax != null ? [xAxisMin!, xAxisMax!] : null;

  /// Returns Y axis minimum and maximum values.
  List<num>? get yAxisMinMax =>
      yAxisMin != null || yAxisMax != null ? [yAxisMin!, yAxisMax!] : null;

  /// The vertical lines of the chart.
  List<VerticalLine>? verticalLines;

  /// The vertical lines default color.
  String verticalLinesDefaultColor = '#ff0000';

  /// Callback for `click` events.
  void Function(List? activeItems, List? xItems, List? yItems)? onClick;

  /// Copies this instance.
  ChartOptions copy();

  void _copyBase(ChartOptions copy) {
    copy.sortCategories = sortCategories;

    copy.xAxisMin = xAxisMin;
    copy.xAxisMax = xAxisMax;

    copy.yAxisMin = yAxisMin;
    copy.yAxisMax = yAxisMax;

    copy.verticalLines =
        verticalLines != null ? List<VerticalLine>.from(verticalLines!) : null;

    copy.verticalLinesDefaultColor = verticalLinesDefaultColor;

    copy.onClick = onClick;
  }
}

/// Possible options for Series Charts.
class ChartSeriesOptions extends ChartOptions {
  /// Draw stepped lines.
  bool steppedLines = false;

  /// Draw straight lines instead of smooth lines.
  bool straightLines = false;

  /// Draw lines area, filling the area beneath them.
  bool fillLines = false;

  @override
  ChartSeriesOptions copy() {
    var copy = ChartSeriesOptions();

    _copyBase(copy);

    copy.straightLines = straightLines;
    copy.fillLines = fillLines;

    return copy;
  }
}

/// Possible options for Set Charts.
class ChartSetOptions extends ChartOptions {
  @override
  ChartSetOptions copy() {
    var copy = ChartSetOptions();
    _copyBase(copy);
    return copy;
  }
}
