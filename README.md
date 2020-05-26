# chart_engine

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
  chart_engine: ^1.0.3
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

You can see [here a live example](./example/www).

If your prefer you can experiment with the example from the source code.

## Example from Sources

Get the source
```shell script
$> git clone https://github.com/Colossus-Services/chart_engine.git
```

...and see the [Web Example][example] (just follow the README file for instructions).

[example]: https://github.com/Colossus-Services/chart_engine/tree/master/example

## Loading Engine JavaScript Libraries

This Dart package already bundles the JavaScript libraries of each supported engine.
When an implementation of `ChartEngine` is instantiated, the corresponding JavaScript library is automatically loaded
and no extra code is needed in your Dart files or HTML files.

The loading processes is made by the package [amdjs.dart][amdjs.dart]. It loads
the JavaScript libraries using AMD framework when an AMD implementation is present and detected,
or injecting a tag ```<script src='lib-x.js'></script>``` as fallback.

[amdjs.dart]: https://github.com/gmpassos/amdjs.dart

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
