# chart_engine

[![pub package](https://img.shields.io/pub/v/chart_engine.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/chart_engine)
[![CI](https://img.shields.io/github/workflow/status/Colossus-Services/chart_engine/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/Colossus-Services/chart_engine/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/Colossus-Services/chart_engine?logo=git&logoColor=white)](https://github.com/Colossus-Services/chart_engine/releases)
[![New Commits](https://img.shields.io/github/commits-since/Colossus-Services/chart_engine/latest?logo=git&logoColor=white)](https://github.com/Colossus-Services/chart_engine/network)
[![Last Commits](https://img.shields.io/github/last-commit/Colossus-Services/chart_engine?logo=git&logoColor=white)](https://github.com/Colossus-Services/chart_engine/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/Colossus-Services/chart_engine?logo=github&logoColor=white)](https://github.com/Colossus-Services/chart_engine/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/Colossus-Services/chart_engine?logo=github&logoColor=white)](https://github.com/Colossus-Services/chart_engine)
[![License](https://img.shields.io/github/license/Colossus-Services/chart_engine?logo=open-source-initiative&logoColor=green)](https://github.com/Colossus-Services/chart_engine/blob/master/LICENSE)
[![Live Example](https://img.shields.io/badge/live-example-brightgreen)][live_example]


Chart generator with interchangeable chart engines, like ChartJS and ApexCharts.

## Engines

- [ApexCharts (v3.19.0)](https://apexcharts.com/).
- [ChartJS (v2.9.3)](https://www.chartjs.org/).

NOTE: You don't need to read any specific documentation of any engine to use `chart_engine`,
since any Chart configuration needed to generate your Chart will be
automatically handled by this package (see the [example][example]).


## Install

```yaml
dependencies:
  chart_engine: ^1.0.10
```

## Usage

A simple example using ApexCharts (ChartsJS is commented):

```dart
import 'dart:html';

//import 'package:chart_engine/chart_engine_chartjs.dart';
import 'package:chart_engine/chart_engine_apexcharts.dart';

void main() async {

  var series = ChartSeries(
      ['Jan','Feb','Mar'],
      {
        'A': [10,20,5] ,
        'B': [15,25,55] ,
        'C': [100,130,140]
      }
  ) ;

  series.title = 'Chart Example' ;
  series.xTitle = 'Months' ;
  series.yTitle = 'Count' ;
  series.options.fillLines = true ;
  series.options.straightLines = true ;

  //var charEngine = ChartEngineChartJS() ;
  var charEngine = ChartEngineApexCharts() ;
  await charEngine.load() ;
  charEngine.renderLineChart( querySelector('#output') , series ) ;


}

```

## Live Example

You can see [here a live example][live_example]

[live_example]: https://colossus-services.github.io/chart_engine/example/www/

If your prefer you can experiment with the example from the source code.

## Example from Sources

Get the source
```
  $> git clone https://github.com/Colossus-Services/chart_engine.git
```

...and see the [Web Example][example] (just follow the README file for instructions).

[example]: https://github.com/Colossus-Services/chart_engine/tree/master/example

## Loading Engines JavaScript Libraries

This Dart package already bundles the JavaScript libraries of each supported engine.
When an implementation of `ChartEngine` is instantiated, the corresponding JavaScript library is automatically loaded
and no extra code is needed in your Dart files or HTML files.

The loading processes is made by the package [amdjs.dart][amdjs.dart]. It loads
the JavaScript libraries using AMD framework when an AMD implementation is present and detected,
or injecting a tag ```<script src='lib-x.js'></script>``` as fallback.

[amdjs.dart]: https://github.com/gmpassos/amdjs.dart

## ChartJS and Moment

You don't need to load Moment JS library to use Time Series Charts when using ChartJS engine.
We implement a fallback Date adapter, using Dart code interoperability,
based in Dart DateTime and DateFormat implementations. ;-P 

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Colossus-Services/chart_engine/issues

## Colossus.Services

This is an open-source project from [Colossus.Services][colossus]:
the gateway for smooth solutions.

[colossus]: https://colossus.services/

## Author

Graciliano M. Passos: [gmpassos@GitHub][gmpassos_github].

[gmpassos_github]: https://github.com/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt
