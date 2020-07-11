## 1.1.1

- Fix VERSION self reference. 

## 1.1.0

- Fix ChartJS gauge chart: center percentage text was drawing over hint.
- Moved color palette generator to project `color_palette_generator`.
- Added testes for `ChartSeries`.
- swiss_knife: ^2.5.4
- dom_tools: ^1.3.2
- amdjs: ^1.0.4

## 1.0.11

- ColorPalette.asHTML(...).
- dartfmt.

## 1.0.10

- Fix ChartEngine.VERSION
- Fix unused import.
- dartfmt

## 1.0.9

- Added support to stepped lines.
- Added central text into Gauge charts.
- Added renderAsync methods (auto load and auto refresh chart onLoad event).
- New color generator: ColorGeneratorFromBasicPalette.
- Optimize ChartData handling of time values.
- Added tests.
- Added badges to README.md
- swiss_knife: ^2.5.2

## 1.0.8

- Added support to Scatter Timed Charts.
- Fix Timed series values sent to JS: convert DateTime to millisecondsSinceEpoch.
- ChartsJS: better Tooltip for Scatter Charts.
- ApexCharts: Fix X axis title position issue, for timed series.

## 1.0.7

- Added support to Scatter Charts.
- ChartData: xAxisScale and yAxisScale
- ChartSeriesPair for Scatter charts.
- swiss_knife: ^2.5.0

## 1.0.6

- Fix version reference.

## 1.0.5

- Fix Dart JS interoperability issues in build release (Dart2JS).

## 1.0.4

- Added support for Time Series Charts (Line charts with DateTime X axis).
- ChartTimeSeries to declare Time Series data.
- Added ChartJS date adapter fallback, in case of moment not present.

## 1.0.3

- Added support to Gauge Charts.
- Added support to disabled colors at ColorGenerator.
- Fix ChartJS build in release mode, since AMDJS is in mimic mode.
- Change SDK requirement from 2.8+ to 2.7+. 
- amdjs: ^1.0.3

## 1.0.2

- Add support to Bar Charts and Horizontal Bar Charts.
- Add examples with Bar Charts.

## 1.0.1

- Fix library name and exports.
- Fix typos.
- dartfmt

## 1.0.0

- Only supporting Line Charts for now.
- Initial version, created by Stagehand
