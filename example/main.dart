import 'dart:html';

//import 'package:chart_engine/chart_engine_apexcharts.dart';
//import 'package:chart_engine/chart_engine_chartjs.dart';
import 'package:chart_engine/chart_engine_all.dart';

void main() async {

  await createLineChart();
  await createBarChart();

}

Future createLineChart() async {

  var series = ChartSeries(
      ['Jan','Feb','Mar'],
      {
        'A': [10,20,5] ,
        'B': [15,25,55] ,
        'C': [100,130,140]
      }
  ) ;

  series.title = 'Line Chart Example' ;
  series.xTitle = 'Months' ;
  series.yTitle = 'Count' ;
  series.options.fillLines = true ;
  series.options.straightLines = true ;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  await charEngine1.load() ;
  charEngine1.renderLineChart( querySelector('#apexcharts-line-output') , series ) ;

  var charEngine2 = ChartEngineChartJS() ;
  await charEngine2.load() ;
  charEngine2.renderLineChart( querySelector('#chartjs-line-output') , series ) ;

}

Future createBarChart() async {

  var set = ChartSet(
      ['Jan','Feb','Mar'],
      {
        'A': [10,20,5] ,
        'B': [15,25,55] ,
        'C': [100,130,140] ,
      }
  ) ;

  set.xTitle = 'Months' ;
  set.yTitle = 'Count' ;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  var charEngine2 = ChartEngineChartJS() ;

  // Simultaneous load engines:
  await Future.wait( [ charEngine1.load() , charEngine2.load() ] ) ;

  set.title = 'Bar Chart Example' ;
  charEngine1.renderBarChart( querySelector('#apexcharts-bar-output') , set ) ;
  charEngine2.renderBarChart( querySelector('#chartjs-bar-output') , set ) ;

  set.title = 'Horizontal Bar Chart Example' ;
  charEngine1.renderHorizontalBarChart( querySelector('#apexcharts-horizontal-bar-output') , set ) ;
  charEngine2.renderHorizontalBarChart( querySelector('#chartjs-horizontal-bar-output') , set ) ;


}


