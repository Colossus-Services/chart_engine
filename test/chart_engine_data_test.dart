@TestOn('browser')
library;

import 'package:chart_engine/chart_engine.dart';
import 'package:swiss_knife/swiss_knife.dart';
import 'package:test/test.dart';

void main() {
  group('ChartData static checks', () {
    test('isValueInUnixEpochRange', () {
      expect(ChartData.isValueInUnixEpochRange(1600000000000), isTrue);
      expect(ChartData.isValueInUnixEpochRange(1000), isFalse);
      expect(ChartData.isValueInUnixEpochRange(1600000000, false), isTrue);
      expect(ChartData.isValueInUnixEpochRange(1600000000000, false), isFalse);
    });

    test('isTimeValue / isValidValue', () {
      expect(ChartData.isTimeValue(DateTime(2020)), isTrue);
      expect(ChartData.isTimeValue(1600000000000), isTrue);
      expect(ChartData.isTimeValue(10), isFalse);
      expect(ChartData.isTimeValue('2020-01-01'), isFalse);

      expect(ChartData.isValidValue(10), isTrue);
      expect(ChartData.isValidValue(1.5), isTrue);
      expect(ChartData.isValidValue(DateTime(2020)), isTrue);
      expect(ChartData.isValidValue('x'), isFalse);
      expect(ChartData.isValidValue(null), isFalse);
    });

    test('isListOfPairs', () {
      expect(
        ChartData.isListOfPairs([
          [1, 2],
          [3, 4],
        ]),
        isTrue,
      );
      expect(ChartData.isListOfPairs([]), isFalse);
      expect(
        ChartData.isListOfPairs([
          [1, 2, 3],
        ]),
        isFalse,
      );
      expect(
        ChartData.isListOfPairs([
          [1, 'a'],
        ]),
        isFalse,
      );
    });

    test('isListOfTimedPairs', () {
      expect(
        ChartData.isListOfTimedPairs([
          [DateTime(2020), 1],
          [1600000000000, 2.5],
        ]),
        isTrue,
      );
      expect(ChartData.isListOfTimedPairs([]), isFalse);
      expect(
        ChartData.isListOfTimedPairs([
          [1, 2],
        ]),
        isFalse,
      );
    });

    test('matches*', () {
      expect(ChartData.matchesSet({'a': 1, 'b': 2.5}), isTrue);
      expect(
        ChartData.matchesSet({
          'a': [1],
        }),
        isFalse,
      );

      expect(
        ChartData.matchesTimeSeries({
          'a': [
            [DateTime(2020), 1],
          ],
        }),
        isTrue,
      );

      expect(
        ChartData.matchesSeriesPair({
          'a': [
            [1, 2],
          ],
        }),
        isTrue,
      );

      expect(ChartData.matchesChartData({'a': 1}), isTrue);
      expect(ChartData.matchesChartData({'a': 'x'}), isFalse);
    });

    test('from', () {
      expect(ChartData.from({'a': 1, 'b': 2}), isA<ChartSet>());

      expect(
        ChartData.from({
          'a': [
            [DateTime(2020, 1, 1), 1],
            [DateTime(2020, 1, 2), 2],
          ],
        }),
        isA<ChartTimeSeries>(),
      );

      var pair = ChartData.from({
        'a': [
          [1, 2],
          [3, 4],
        ],
      });
      expect(pair, isA<ChartSeriesPair>());
      expect(pair, isNot(isA<ChartTimeSeries>()));

      expect(
        ChartData.from({
          'a': [
            [1, 2, 3],
          ],
        }),
        allOf(isA<ChartSeries>(), isNot(isA<ChartSeriesPair>())),
      );

      expect(ChartData.from({'a': 'x'}), isNull);
    });
  });

  group('ChartSeries', () {
    ChartSeries<String, String, int, int> newSeries() => ChartSeries(
      ['jan', 'feb', 'mar'],
      {
        'b': [10, 20, 30],
        'c': [5, 50, 15],
        'a': [1, 2, 3],
      },
    );

    test('basic accessors', () {
      var s = newSeries();

      expect(s.isEmpty, isFalse);
      expect(s.isNotEmpty, isTrue);
      expect(s.categories, equals(['b', 'c', 'a']));
      expect(s.categoriesAsStrings, equals(['b', 'c', 'a']));
      expect(s.getXAxisValue(1), equals('feb'));
      expect(s.xAxisAllValues, equals(['jan', 'feb', 'mar']));
      expect(s.yAxisAllValues, equals([10, 20, 30, 5, 50, 15, 1, 2, 3]));
      expect(s.options, isA<ChartSeriesOptions>());

      expect(ChartSeries([], {}).isEmpty, isTrue);
    });

    test('seriesSortedByCategory', () {
      var s = newSeries();
      expect(s.seriesSortedByCategory.keys, equals(['a', 'b', 'c']));
      expect(s.seriesSortedByCategory['c'], equals([5, 50, 15]));
      // Original order is untouched:
      expect(s.series.keys, equals(['b', 'c', 'a']));
    });

    test('seriesSortedByCategory (untyped)', () {
      var s = ChartSeries([], {
        'b': [1],
        'a': [2],
      });
      expect(s.seriesSortedByCategory.keys, equals(['a', 'b']));
    });

    test('yAxisScale', () {
      var scale = newSeries().yAxisScale!;
      expect(scale, isA<Scale<int>>());
      expect(scale.minimum, equals(1));
      expect(scale.maximum, equals(50));
      expect(scale.length, equals(49));
    });

    test('yAxisScale (double / untyped)', () {
      var d = ChartSeries<String, String, double, double>([], {
        'a': [1.5, 0.5],
      });
      expect(d.yAxisScale, isA<Scale<double>>());
      expect(d.yAxisScale!.minimum, equals(0.5));

      var u = ChartSeries([], {
        'a': [3, 1.5],
      });
      expect(u.yAxisScale!.minimum, equals(1.5));
      expect(u.yAxisScale!.maximum, equals(3));

      expect(ChartSeries<String, String, int, int>([], {}).yAxisScale, isNull);
    });

    test('colors', () {
      var s = newSeries();
      expect(s.colors, isNull);

      s.ensureColors(StandardColorGenerator());

      expect(s.colors!.keys, equals(['b', 'c', 'a']));
      expect(s.disabledColors!.keys, equals(['b', 'c', 'a']));
      for (var c in s.colors!.values) {
        expect(HTMLColor.from(c), isNotNull, reason: 'Invalid color: $c');
      }

      expect(s.colorsLighter.keys, equals(s.colors!.keys));
      expect(s.colorsDarker.keys, equals(s.colors!.keys));
      expect(s.colorsLighter['a'], isNot(equals(s.colorsDarker['a'])));

      // ensureColors must not override user colors:
      var custom = {'a': '#ff0000', 'b': '#00ff00', 'c': '#0000ff'};
      s.colors = Map.of(custom);
      s.ensureColors(StandardColorGenerator());
      expect(s.colors, equals(custom));

      // setColors always overrides:
      s.setColors(StandardColorGenerator());
      expect(s.colors, isNot(equals(custom)));
    });

    test('lastRenderedChart not populated by default', () {
      var s = newSeries();
      expect(s.populateLastRenderedChart, isFalse);
      expect(s.lastRenderedChart, isNull);
    });
  });

  group('ChartSeriesPair', () {
    test('List pairs: getPairX/Y and scales', () {
      var s = ChartSeriesPair({
        'a': [
          [1, 10],
          [2, 20],
        ],
        'b': [
          [3, 5],
        ],
      });

      expect(s.getPairX([1, 10]), equals(1));
      expect(s.getPairY([1, 10]), equals(10));
      expect(s.getXAxisValue(1), equals(2));
      expect(s.xAxisAllValues, equals([1, 2, 3]));
      expect(s.yAxisAllValues, equals([10, 20, 5]));
      expect(s.xAxisScale!.minimum, equals(1));
      expect(s.xAxisScale!.maximum, equals(3));
      expect(s.yAxisScale!.minimum, equals(5));
      expect(s.yAxisScale!.maximum, equals(20));
    });

    test('Map pairs with alternative keys', () {
      var s = ChartSeriesPair({
        'a': [
          {'time': 1, 'value': 10},
          {'t': 2, 'v': 20},
        ],
      });

      expect(s.xAxisAllValues, equals([1, 2]));
      expect(s.yAxisAllValues, equals([10, 20]));

      expect(
        s.seriesAsPairsOfList()['a'],
        equals([
          [1, 10],
          [2, 20],
        ]),
      );
      expect(
        s.seriesAsPairsOfMap()['a'],
        equals([
          {'x': 1, 'y': 10},
          {'x': 2, 'y': 20},
        ]),
      );
    });

    test('Custom xKeys / yKeys', () {
      var s = ChartSeriesPair({
        'a': [
          {'foo': 1, 'bar': 10},
        ],
      });

      s.xKeys = ['foo'];
      s.yKeys = ['bar'];

      expect(s.getPairX({'foo': 1, 'bar': 10}), equals(1));
      expect(s.getPairY({'foo': 1, 'bar': 10}), equals(10));
    });

    test('Pair and String pairs', () {
      var s = ChartSeriesPair<String, dynamic, dynamic, dynamic>({
        'a': [Pair(1, 10), '2 ; 20'],
      });

      expect(s.getPairX(Pair(1, 10)), equals(1));
      expect(s.getPairY(Pair(1, 10)), equals(10));
      expect(s.getPairX('2 ; 20'), equals('2'));
      expect(s.getPairY('2 ; 20'), equals('20'));
      expect(() => s.getPairX(123), throwsUnsupportedError);
      expect(s.getPairX(null), isNull);
    });

    test('swapXY', () {
      var s =
          ChartSeriesPair<String, dynamic, dynamic, dynamic>({
              'list': [
                [1, 10],
              ],
              'map': [
                {'x': 2, 'y': 20},
              ],
              'string': ['3,30'],
              'pair': [Pair(4, 40)],
            })
            ..title = 'T'
            ..xTitle = 'X'
            ..yTitle = 'Y'
            ..colors = {'list': '#ff0000'};

      s.options.fillLines = true;

      var swapped = s.swapXY();

      expect(
        swapped.series['list'],
        equals([
          [10, 1],
        ]),
      );
      expect(
        swapped.series['map'],
        equals([
          {'x': 20, 'y': 2},
        ]),
      );
      expect(swapped.series['string'], equals(['30,3']));
      expect((swapped.series['pair']![0] as Pair).a, equals(40));
      expect((swapped.series['pair']![0] as Pair).b, equals(4));

      expect(swapped.title, equals('T'));
      expect(swapped.xTitle, equals('Y'));
      expect(swapped.yTitle, equals('X'));
      expect(swapped.colors, equals({'list': '#ff0000'}));
      expect(swapped.options.fillLines, isTrue);
      expect(identical(swapped.options, s.options), isFalse);

      // Original untouched:
      expect(
        s.series['list'],
        equals([
          [1, 10],
        ]),
      );
    });

    test('swapPairAsString keeps delimiter', () {
      var s = ChartSeriesPair({});
      expect(s.swapPairAsString('1|2'), equals('2|1'));
      expect(s.swapPairAsString('1 : 2'), equals('2 : 1'));
      expect(s.swapPairAsString('1'), equals('1'));
    });

    test('seriesAsPairsOfList: sort and custom mappers', () {
      var s = ChartSeriesPair({
        'b': [
          [1, 2],
        ],
        'a': [
          [3, 4],
        ],
      });

      expect(
        s.seriesAsPairsOfList(sortSeriesByCategory: true).keys,
        equals(['a', 'b']),
      );

      var mapped = s.seriesPairsAsList(
        xMapper: (o) => (o as int) * 10,
        yMapper: (o) => '$o',
      );
      expect(
        mapped['b'],
        equals([
          [10, '2'],
        ]),
      );
    });
  });

  group('ChartTimeSeries', () {
    final d1 = DateTime(2020, 1, 1);
    final d2 = DateTime(2020, 1, 2);
    final d3 = DateTime(2020, 1, 3);

    test('sorts pairs by date', () {
      var s = ChartTimeSeries({
        'a': [
          [d3, 3],
          [d1, 1],
          [d2, 2],
        ],
      });

      expect(
        s.series['a'],
        equals([
          [d1, 1],
          [d2, 2],
          [d3, 3],
        ]),
      );
    });

    test('normalizes ISO string dates and epoch ints', () {
      var s = ChartTimeSeries({
        'iso': [
          ['2020-01-02', '20'],
          ['2020-01-01', '10'],
        ],
        'epoch': [
          [5, d2.millisecondsSinceEpoch],
          [d1.millisecondsSinceEpoch, 7],
        ],
      });

      expect(
        s.series['iso'],
        equals([
          [d1, 10],
          [d2, 20],
        ]),
      );
      expect(
        s.series['epoch'],
        equals([
          [d1, 7],
          [d2, 5],
        ]),
      );
    });

    test('seriesAsPairsOfMap maps DateTime to millis', () {
      var s = ChartTimeSeries({
        'a': [
          [d1, 1],
        ],
      });

      expect(
        s.seriesAsPairsOfMap()['a'],
        equals([
          {'x': d1.millisecondsSinceEpoch, 'y': 1},
        ]),
      );
      expect(
        s.seriesAsPairsOfMap(mapDateTimeToMillis: false)['a'],
        equals([
          {'x': d1, 'y': 1},
        ]),
      );
    });

    test('seriesDateTimeMinMax / allSeriesDateTimeMinMax', () {
      var s = ChartTimeSeries({
        'a': [
          [d2, 1],
          [d1, 2],
        ],
        'b': [
          [d3, 3],
        ],
      });

      expect(
        s.seriesDateTimeMinMax(),
        equals({
          'a': [d1, d2],
          'b': [d3, d3],
        }),
      );
      expect(s.allSeriesDateTimeMinMax(), equals([d1, d3]));

      expect(ChartTimeSeries({}).allSeriesDateTimeMinMax(), isNull);
    });

    test('seriesAsEntriesOfTOHLC', () {
      var s = ChartTimeSeries({
        'a': [
          [d2, 20, 25, 15, 22],
          [d1, 10, 15, 5, 12],
        ],
      });

      expect(
        s.seriesAsEntriesOfTOHLC()['a'],
        equals([
          {'t': d1.millisecondsSinceEpoch, 'o': 10, 'h': 15, 'l': 5, 'c': 12},
          {'t': d2.millisecondsSinceEpoch, 'o': 20, 'h': 25, 'l': 15, 'c': 22},
        ]),
      );
    });

    test('xAxisAllValues are DateTime', () {
      var s = ChartTimeSeries({
        'a': [
          [d1, 1],
          [d2, 2],
        ],
      });

      expect(s.xAxisAllValues, equals([d1, d2]));
      expect(s.getXAxisValue(0), equals(d1));
    });
  });

  group('ChartSet', () {
    ChartSet<String, int> newSet() => ChartSet({'b': 20, 'a': 10, 'c': 30});

    test('accessors', () {
      var s = newSet();

      expect(s.isEmpty, isFalse);
      expect(s.categories, equals(['b', 'a', 'c']));
      expect(s.xLabels, equals(['b', 'a', 'c']));
      expect(s.getXAxisValue(2), equals('c'));
      expect(s.xAxisAllValues, equals(['b', 'a', 'c']));
      expect(s.yAxisAllValues, equals([20, 10, 30]));
      expect(s.setSorted.keys, equals(['a', 'b', 'c']));
      expect(ChartSet({'y': 1, 'x': 2}).setSorted.keys, equals(['x', 'y']));
      expect(s.options, isA<ChartSetOptions>());

      expect(ChartSet({}).isEmpty, isTrue);
    });

    test('yAxisScale', () {
      var scale = newSet().yAxisScale!;
      expect(scale.minimum, equals(10));
      expect(scale.maximum, equals(30));
    });

    test('asChartSeries', () {
      var series = newSet().asChartSeries;
      expect(
        series.series,
        equals({
          'b': [20],
          'a': [10],
          'c': [30],
        }),
      );
    });
  });

  group('ChartOptions', () {
    test('axis min/max', () {
      var o = ChartSeriesOptions();
      expect(o.xAxisMinMax, isNull);
      expect(o.yAxisMinMax, isNull);

      o
        ..xAxisMin = 0
        ..xAxisMax = 10
        ..yAxisMin = -5
        ..yAxisMax = 5;

      expect(o.xAxisMinMax, equals([0, 10]));
      expect(o.yAxisMinMax, equals([-5, 5]));
    });

    test('ChartSeriesOptions.copy', () {
      void onClick(List? a, List? x, List? y) {}

      var o = ChartSeriesOptions()
        ..sortCategories = true
        ..xAxisMin = 1
        ..xAxisMax = 2
        ..yAxisMin = 3
        ..yAxisMax = 4
        ..verticalLines = [VerticalLine(1, label: 'L')]
        ..verticalLinesDefaultColor = '#00ff00'
        ..onClick = onClick
        ..steppedLines = true
        ..straightLines = true
        ..fillLines = true;

      var c = o.copy();

      expect(identical(c, o), isFalse);
      expect(c.sortCategories, isTrue);
      expect(c.xAxisMinMax, equals([1, 2]));
      expect(c.yAxisMinMax, equals([3, 4]));
      expect(c.verticalLines!.single.label, equals('L'));
      expect(identical(c.verticalLines, o.verticalLines), isFalse);
      expect(c.verticalLinesDefaultColor, equals('#00ff00'));
      expect(c.onClick, same(o.onClick));
      expect(c.steppedLines, isTrue);
      expect(c.straightLines, isTrue);
      expect(c.fillLines, isTrue);
    });

    test('ChartSetOptions.copy', () {
      var o = ChartSetOptions()
        ..sortCategories = true
        ..yAxisMin = 0
        ..yAxisMax = 100;

      var c = o.copy();
      expect(c, isA<ChartSetOptions>());
      expect(c.sortCategories, isTrue);
      expect(c.yAxisMinMax, equals([0, 100]));
    });
  });

  group('VerticalLine', () {
    test('valid', () {
      var l = VerticalLine(
        2,
        label: 'x',
        color: '#fff',
        yPosition: 0.5,
        textAlign: 'left',
      );
      expect(l.index, equals(2));
      expect(l.toString(), contains('label: x'));
    });

    test('negative index throws', () {
      expect(() => VerticalLine(-1), throwsArgumentError);
    });
  });
}
