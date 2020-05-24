import 'dart:html';

//import 'package:chart_engine/chart_engine_apexcharts.dart';
//import 'package:chart_engine/chart_engine_chartjs.dart';
import 'package:chart_engine/chart_engine_all.dart';

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

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  await charEngine1.load() ;
  charEngine1.renderLineChart( querySelector('#apexcharts-output') , series ) ;

  var charEngine2 = ChartEngineChartJS() ;
  await charEngine2.load() ;
  charEngine2.renderLineChart( querySelector('#chartjs-output') , series ) ;

}
