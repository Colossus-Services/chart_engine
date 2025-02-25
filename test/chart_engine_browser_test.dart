@TestOn('browser')
library;

import 'package:chart_engine/chart_engine_all.dart';
import 'package:test/test.dart';
import 'package:web_utils/web_utils.dart';

Future<void> _sleep(int sleepMs) async {
  if (sleepMs <= 0) return;
  print('SLEEP> ${sleepMs}ms');
  await Future.delayed(Duration(milliseconds: sleepMs), () {});
}

void _createLineChart(ChartEngine charEngine) async {
  var series = ChartSeries([
    'Jan',
    'Feb',
    'Mar'
  ], {
    'A': [10, 20, 5],
    'B': [15, 25, 55],
    'C': [100, 130, 140]
  });

  var output =
      document.body!.appendChild(HTMLDivElement()..style.width = '100%');

  expect(output.childNodes.isEmpty, isTrue);

  charEngine.renderLineChart(output as HTMLElement, series);

  await _sleep(500);

  expect(output.childNodes.isEmpty, isFalse);
}

void main() {
  group('ChartEngine Browser', () {
    setUp(() {});

    test('ChartJS', () async {
      var engine = ChartEngineChartJS();

      expect(engine.isLoaded, isFalse);

      var loadOK = await engine.load();

      expect(loadOK, isTrue);

      expect(engine.isLoaded, isTrue);

      _createLineChart(engine);
    });

    test('Apexcharts', () async {
      var engine = ChartEngineApexCharts();

      expect(engine.isLoaded, isFalse);

      var loadOK = await engine.load();

      expect(loadOK, isTrue);

      expect(engine.isLoaded, isTrue);

      _createLineChart(engine);
    });
  });
}
