## 2.1.1

- sdk: '>=3.5.0 <4.0.0'

- swiss_knife: ^3.2.3
- dom_tools: ^2.3.2
- amdjs: ^2.0.4

- lints: ^5.1.1
- test: ^1.25.15
- path: ^1.9.1
- build_runner: ^2.4.15
- build_web_compilers: ^4.1.1
- collection: ^1.19.1

## 2.1.0

- sdk: '>=3.3.0 <4.0.0'

- swiss_knife: ^3.2.0
- dom_tools: ^2.3.0
- color_palette_generator: ^2.0.1
- intl: ^0.19.0

- lints: ^3.0.0
- test: ^1.25.2
- path: ^1.9.0
- dependency_validator: ^3.2.3
- build_runner: ^2.4.8
- build_web_compilers: ^4.0.9
- collection: ^1.18.0

## 2.0.5

- swiss_knife: ^3.1.3
- dom_tools: ^2.1.9
- intl: ^0.18.0
- lints: ^2.0.1
- test: ^1.22.1
- path: ^1.8.3
- dependency_validator: ^3.2.2
- build_runner: ^2.3.3
- build_web_compilers: ^3.2.7
- collection: ^1.16.0

## 2.0.4

- Improved GitHub CI.
- swiss_knife: ^3.1.1
- dom_tools: ^2.1.1
- amdjs: ^2.0.3
- dependency_validator: ^3.1.0

## 2.0.3

- Dart `2.16`:
  - Organize imports.
  - Fix new lints (breaks some enum names).
- sdk: '>=2.13.0 <3.0.0'
- swiss_knife: ^3.0.8
- dom_tools: ^2.1.0
- amdjs: ^2.0.2
- lints: ^1.0.1

## 2.0.2

- Upgrade Chart.js to `v2.9.4`.
- Upgrade ApexCharts to `v3.26.0`.
- sdk: '>=2.13.0 <3.0.0':
  - Dart `2.13.0`+ is needed to use `build_runner` and
    `build_web_compilers` with Null Safety.

## 2.0.1

- Sound null safety compatibility.
- swiss_knife: ^3.0.6
- dom_tools: ^2.0.1
- amdjs: ^2.0.1

## 2.0.0-nullsafety.2

- Null Safety adjustments.
- swiss_knife: ^3.0.5

## 2.0.0-nullsafety.1

- Dart 2.12.0:
  - Sound null safety compatibility.
  - Update CI dart commands.
  - sdk: '>=2.12.0 <3.0.0'
- swiss_knife: ^3.0.1
- dom_tools: ^2.0.0-nullsafety.1
- color_palette_generator: ^2.0.0
- amdjs: ^2.0.0-nullsafety.1
- intl: ^0.17.0
- collection: ^1.15.0-nullsafety.4

## 1.1.11

- New `RenderedChart` class, returned by every render.
- `ChartOptions`: Added `onClick`.
- swiss_knife: ^2.5.26
- dom_tools: ^1.3.20
- color_palette_generator: ^1.0.4
- amdjs: ^1.0.7

## 1.1.10

- `ChartOptions`:
  - Added: `xAxisMin`, `xAxisMax`, `yAxisMin`, `yAxisMax`.
  - Added: `verticalLines`.
- `ApexCharts`:
  - Fix series order to be rendered in the same order of ChartJS.

## 1.1.9

- Financial Chart with color scheme for each series,
  allowing better multiple serias visualization.
- ChartJS: better identification of output dimension and canvas size.
- color_palette_generator: ^1.0.3
- dom_tools: ^1.3.13

## 1.1.8

- ChartJS:
  - Added Financial Chart: Candlestick and OHLC.
- Added Candlestick and OHLC examples.
- swiss_knife: ^2.5.15
- dom_tools: ^1.3.12

## 1.1.7

- Upgrade engine ApexCharts to v3.20.2.
- swiss_knife: ^2.5.14
- dom_tools: ^1.3.11

## 1.1.6

- swiss_knife: ^2.5.12
- dom_tools: ^1.3.10
- color_palette_generator: ^1.0.2
- amdjs: ^1.0.6
- pedantic: ^1.9.2
- test: ^1.15.3

## 1.1.5

- dom_tools: ^1.3.6
- swiss_knife: ^2.5.8
- CI: VM + Browser tests 

## 1.1.4

- ChartTimeSeries: always sort pairs by date, avoiding odd timelines.
- ChartEngine.render: warns for an output Element without `parent`, that will break some engines.
- CI: added browser test (firefox).

## 1.1.3

- Fix ChartEngine.VERSION self reference.
- Added test to check if ChartEngine.VERSION is the same of pubspec. 

## 1.1.2

- dom_tools: ^1.3.3
- amdjs: ^1.0.5
- dartfmt

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
