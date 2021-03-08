@TestOn('browser')

import 'package:chart_engine/src/chart_engine_series.dart';
import 'package:test/test.dart';

void main() {
  group('ColorPalette', () {
    setUp(() {});

    test('ChartSeries', () {
      var chartSeries = ChartSeries([
        'jan',
        'feb',
        'mar'
      ], {
        'spot1': [100, 200, 300],
        'spot2': [110, 210, 310],
        'spot3': [250, 150, 120]
      });

      expect(chartSeries.xLabels, equals(['jan', 'feb', 'mar']));

      expect(chartSeries.series['spot1'], equals([100, 200, 300]));
      expect(chartSeries.series['spot2'], equals([110, 210, 310]));
      expect(chartSeries.series['spot3'], equals([250, 150, 120]));
    });

    test('ChartTimeSeries String pairs', () {
      var now = DateTime.now().millisecondsSinceEpoch;

      var chartSeries = ChartTimeSeries({
        'spot1': [
          '100,${now + 1000}',
          '200,${now + 2000}',
          '300,${now + 3000}'
        ],
        'spot2': [
          '${now + 1000},110',
          '${now + 2000},210',
          '${now + 3000},310'
        ],
      });

      expect(chartSeries.xLabels, equals([]));

      expect(
          chartSeries.series['spot1'],
          equals([
            [DateTime.fromMillisecondsSinceEpoch(now + 1000), 100].join(','),
            [DateTime.fromMillisecondsSinceEpoch(now + 2000), 200].join(','),
            [DateTime.fromMillisecondsSinceEpoch(now + 3000), 300].join(','),
          ]));

      expect(
          chartSeries.series['spot2'],
          equals([
            [DateTime.fromMillisecondsSinceEpoch(now + 1000), 110].join(','),
            [DateTime.fromMillisecondsSinceEpoch(now + 2000), 210].join(','),
            [DateTime.fromMillisecondsSinceEpoch(now + 3000), 310].join(','),
          ]));
    });

    test('ChartTimeSeries DateTime+int pair', () {
      var now = DateTime.now().millisecondsSinceEpoch;

      var chartSeries = ChartTimeSeries({
        'spot1': [
          [100, DateTime.fromMillisecondsSinceEpoch(now + 1000)],
          [200, DateTime.fromMillisecondsSinceEpoch(now + 2000)],
          [300, DateTime.fromMillisecondsSinceEpoch(now + 3000)]
        ],
        'spot2': [
          [DateTime.fromMillisecondsSinceEpoch(now + 1000), 110],
          [DateTime.fromMillisecondsSinceEpoch(now + 2000), 220],
          [DateTime.fromMillisecondsSinceEpoch(now + 3000), 330]
        ],
      });

      expect(chartSeries.xLabels, equals([]));

      expect(
          chartSeries.series['spot1'],
          equals([
            [DateTime.fromMillisecondsSinceEpoch(now + 1000), 100],
            [DateTime.fromMillisecondsSinceEpoch(now + 2000), 200],
            [DateTime.fromMillisecondsSinceEpoch(now + 3000), 300]
          ]));

      expect(
          chartSeries.series['spot2'],
          equals([
            [DateTime.fromMillisecondsSinceEpoch(now + 1000), 110],
            [DateTime.fromMillisecondsSinceEpoch(now + 2000), 220],
            [DateTime.fromMillisecondsSinceEpoch(now + 3000), 330]
          ]));
    });

    test('ChartSeriesPair', () {
      var chartSeries = ChartSeriesPair({
        'spot1': [
          [1000, 100],
          [2000, 200],
          [3000, 300]
        ],
        'spot2': [
          [1000, 110],
          [2000, 220],
          [3000, 330]
        ],
      });

      expect(chartSeries.xLabels, equals([]));

      expect(
          chartSeries.series['spot1'],
          equals([
            [1000, 100],
            [2000, 200],
            [3000, 300]
          ]));
      expect(
          chartSeries.series['spot2'],
          equals([
            [1000, 110],
            [2000, 220],
            [3000, 330]
          ]));

      expect(
          chartSeries.seriesAsPairsOfList()['spot1'],
          equals([
            [1000, 100],
            [2000, 200],
            [3000, 300]
          ]));
      expect(
          chartSeries.seriesAsPairsOfList()['spot2'],
          equals([
            [1000, 110],
            [2000, 220],
            [3000, 330]
          ]));

      expect(
          chartSeries.seriesAsPairsOfMap()['spot1'],
          equals([
            {'x': 1000, 'y': 100},
            {'x': 2000, 'y': 200},
            {'x': 3000, 'y': 300}
          ]));
      expect(
          chartSeries.seriesAsPairsOfMap()['spot2'],
          equals([
            {'x': 1000, 'y': 110},
            {'x': 2000, 'y': 220},
            {'x': 3000, 'y': 330}
          ]));

      var xScale = chartSeries.xAxisScale;
      expect(xScale.minimum, equals(1000));
      expect(xScale.maximum, equals(3000));
      expect(xScale.length, equals(2000));

      var yScale = chartSeries.yAxisScale;
      expect(yScale.minimum, equals(100));
      expect(yScale.maximum, equals(330));
      expect(yScale.length, equals(230));
    });
  });
}
