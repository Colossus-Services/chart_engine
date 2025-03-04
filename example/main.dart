// ignore: deprecated_member_use
import 'dart:html';

import 'package:chart_engine/chart_engine_all.dart';

void main() async {
  querySelector('#apexcharts_version')!.text = ChartEngineApexCharts().version;
  querySelector('#chartjs_version')!.text = ChartEngineChartJS().version;

  await createLineChart();
  await createTimeSeriesChart();

  await createBarChart();

  await createScatterChart();
  await createScatterTimedChart();

  await createGaugeChart();

  await createFinancialChart();

  querySelector('#chart-version')!.text = ChartEngine.VERSION;
}

Future createLineChart() async {
  var series = ChartSeries([
    'Jan',
    'Feb',
    'Mar'
  ], {
    'A': [10, 20, 5],
    'B': [15, 25, 55],
    'C': [100, 130, 140]
  });

  series.title = 'Line Chart Example';
  series.xTitle = 'Months';
  series.yTitle = 'Count';
  series.options.straightLines = true;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  await charEngine1.load();
  await charEngine2.load();

  charEngine1.renderLineChart(
      querySelector('#apexcharts-line1-output')!, series);
  charEngine2.renderLineChart(querySelector('#chartjs-line1-output')!, series);

  series.options.fillLines = true;
  series.options.verticalLines = [VerticalLine(1, label: 'Mark', yPosition: 1)];

  charEngine1.renderLineChart(
      querySelector('#apexcharts-line2-output')!, series);
  charEngine2.renderLineChart(querySelector('#chartjs-line2-output')!, series);
}

Future createTimeSeriesChart() async {
  // Declare using pair of x(DateTime) and y(value) entries.
  var series = ChartTimeSeries({
    'A': [
      [DateTime(2020, 03, 30), 10],
      [DateTime(2020, 03, 31), 20],
      [DateTime(2020, 04, 01), 5],
      [DateTime(2020, 04, 02), -10],
      [DateTime(2020, 04, 03), 1]
    ],
    'B': [
      [DateTime(2020, 03, 30), 15],
      [DateTime(2020, 03, 31), 25],
      [DateTime(2020, 04, 01), 55],
      [DateTime(2020, 04, 02), 30],
      [DateTime(2020, 04, 03), -10]
    ],
    'C': [
      [100, DateTime(2020, 03, 30)],
      [DateTime(2020, 03, 31), 130],
      [DateTime(2020, 04, 01), 140],
      [DateTime(2020, 04, 02), -20],
      [DateTime(2020, 04, 03), -55]
    ],
  });

  series.title = 'Time Series Chart Example';
  series.xTitle = 'Months';
  series.yTitle = 'Count';

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  // Simultaneous load engines:
  await Future.wait([charEngine1.load(), charEngine2.load()]);

  charEngine1.renderTimeSeriesChart(
      querySelector('#apexcharts-time_series-output')!, series);
  charEngine2.renderTimeSeriesChart(
      querySelector('#chartjs-time_series-output')!, series);
}

Future createBarChart() async {
  var series = ChartSeries([
    'Jan',
    'Feb',
    'Mar'
  ], {
    'A': [10, 20, 5],
    'B': [15, 25, 55],
    'C': [100, 130, 140],
  });

  series.xTitle = 'Months';
  series.yTitle = 'Count';

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  // Simultaneous load engines:
  await Future.wait([charEngine1.load(), charEngine2.load()]);

  series.title = 'Bar Chart Example';
  charEngine1.renderBarChart(querySelector('#apexcharts-bar-output')!, series);
  charEngine2.renderBarChart(querySelector('#chartjs-bar-output')!, series);

  series.title = 'Horizontal Bar Chart Example';
  charEngine1.renderHorizontalBarChart(
      querySelector('#apexcharts-horizontal-bar-output')!, series);
  charEngine2.renderHorizontalBarChart(
      querySelector('#chartjs-horizontal-bar-output')!, series);
}

Future createScatterChart() async {
  // Declare using pair of x(height:cm) and y(weight: kg) entries.
  var series = ChartSeriesPair({
    'A': [
      [167.08, 61.25],
      [171.75, 66.77],
      [174.96, 75.11],
      [175.79, 88.40],
      [173.48, 78.86]
    ],
    'B': [
      [175.77, 50.87],
      [174.98, 72.38],
      [166.27, 52.59],
      [172.75, 66.85],
      [184.17, 90.71]
    ],
    'C': [
      [180.59, 98.12],
      [165.89, 58.20],
      [166.42, 50.33],
      [181.33, 78.01],
      [181.66, 101.91]
    ],
  });

  series.title = 'Scatter Chart Example';
  series.xTitle = 'Height';
  series.yTitle = 'Weight';

  // Swap X and Y values, including xTitle and yTitle.
  var series2 = series.swapXY();

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  // Simultaneous load engines:
  await Future.wait([charEngine1.load(), charEngine2.load()]);

  charEngine1.renderScatterChart(
      querySelector('#apexcharts-scatter-output')!, series2);
  charEngine2.renderScatterChart(
      querySelector('#chartjs-scatter-output')!, series2);
}

Future createScatterTimedChart() async {
  // Declare using pair of x(DateTime) and y(value) entries.
  var series = ChartTimeSeries({
    'A': [
      [DateTime(2020, 03, 30), 10],
      [DateTime(2020, 03, 31), 20],
      [DateTime(2020, 04, 01, 10), 5],
      [DateTime(2020, 04, 02, 3), -10],
      [DateTime(2020, 04, 03, 11), 1]
    ],
    'B': [
      [DateTime(2020, 03, 30, 2), 15],
      [DateTime(2020, 03, 31, 3), 25],
      [DateTime(2020, 04, 01, 12), 55],
      [DateTime(2020, 04, 02, 14), 30],
      [DateTime(2020, 04, 03, 2), -10]
    ],
    'C': [
      [100, DateTime(2020, 03, 30, 5)],
      [DateTime(2020, 03, 31, 4), 130],
      [DateTime(2020, 04, 01, 20), 140],
      [DateTime(2020, 04, 02, 23), -20],
      [DateTime(2020, 04, 03, 18), -55]
    ],
  });

  series.title = 'Scatter Timed Chart Example';
  series.xTitle = 'Months';
  series.yTitle = 'Count';

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  // Simultaneous load engines:
  await Future.wait([charEngine1.load(), charEngine2.load()]);

  charEngine1.renderScatterTimedChart(
      querySelector('#apexcharts-scatter_timed-output')!, series);
  charEngine2.renderScatterTimedChart(
      querySelector('#chartjs-scatter_timed-output')!, series);
}

Future createGaugeChart() async {
  // Using Set: 1 value per category.
  // For Gauge needs to be in range of 0% to 100%.
  var set = ChartSet({
    'A': 60,
    'B': 75,
    'C': 50,
  });

  set.title = 'Gauge Chart Example';

  var charEngine1 = ChartEngineApexCharts();
  var charEngine2 = ChartEngineChartJS();

  // Simultaneous load engines:
  await Future.wait([charEngine1.load(), charEngine2.load()]);

  charEngine1.renderGaugeChart(querySelector('#apexcharts-gauge-output')!, set);
  charEngine2.renderGaugeChart(querySelector('#chartjs-gauge-output')!, set);
}

Future createFinancialChart() async {
  var series = ChartTimeSeries({
    'StockX': [
      [DateTime(2020, 03, 30, 12), 10, 20, 10, 20],
      [DateTime(2020, 03, 31, 12), 20, 20, 2, 5],
      [DateTime(2020, 04, 01, 12), 5, 10, -10, -10],
      [DateTime(2020, 04, 02, 12), -10, 5, -15, 1],
      [DateTime(2020, 04, 03, 12), 1, 15, -1, 15],
      [DateTime(2020, 04, 04, 12), 15, 25, 10, 25],
      [DateTime(2020, 04, 05, 12), 25, 60, 25, 55],
      [DateTime(2020, 04, 06, 12), 55, 60, 40, 55],
      [DateTime(2020, 04, 07, 12), 55, 60, -10, -10],
      [DateTime(2020, 04, 08, 12), -10, -10, 0, 0]
    ],
    'StockY': [
      [DateTime(2020, 03, 30, 12), 100, 200, 100, 200],
      [DateTime(2020, 03, 31, 12), 200, 200, 20, 50],
      [DateTime(2020, 04, 01, 12), 50, 100, 30, 30],
      [DateTime(2020, 04, 02, 12), 30, 50, 20, 25],
      [DateTime(2020, 04, 03, 12), 30, 150, 10, 150],
      [DateTime(2020, 04, 04, 12), 150, 250, 100, 250],
      [DateTime(2020, 04, 05, 12), 250, 600, 250, 550],
      [DateTime(2020, 04, 06, 12), 550, 550, 300, 300],
      [DateTime(2020, 04, 07, 12), 300, 300, 20, 30],
      [DateTime(2020, 04, 08, 12), 30, 40, 0, 20]
    ],
  });

  series.xTitle = 'Months';
  series.yTitle = 'Value';
  series.options.straightLines = true;

  var charEngine2 = ChartEngineChartJS();

  charEngine2.colorGenerator = StandardColorGenerator.scheme('Financial');

  await charEngine2.loadFinancial();

  series.title = 'Financial Chart (OHLC) Example';
  charEngine2.renderFinancialChart(
      querySelector('#chartjs-financial-ohlc-output')!, series,
      ohlc: true);

  series.title = 'Financial Chart (Candlestick) Example';
  charEngine2.renderFinancialChart(
      querySelector('#chartjs-financial-candle-output')!, series,
      candlestick: true);
}
