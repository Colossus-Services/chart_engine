import 'dart:html';

//import 'package:chart_engine/chart_engine_apexcharts.dart';
//import 'package:chart_engine/chart_engine_chartjs.dart';
import 'package:chart_engine/chart_engine_all.dart';

void main() async {

  await createLineChart();
  await createTimeSeriesChart();

  await createBarChart();
  await createGaugeChart();

  querySelector('#chart-version').text = '${ ChartEngine.VERSION }' ;


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
  series.options.straightLines = true ;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  var charEngine2 = ChartEngineChartJS() ;

  await charEngine1.load() ;
  await charEngine2.load() ;

  charEngine1.renderLineChart( querySelector('#apexcharts-line1-output') , series ) ;
  charEngine2.renderLineChart( querySelector('#chartjs-line1-output') , series ) ;

  series.options.fillLines = true ;

  charEngine1.renderLineChart( querySelector('#apexcharts-line2-output') , series ) ;
  charEngine2.renderLineChart( querySelector('#chartjs-line2-output') , series ) ;

}


Future createTimeSeriesChart() async {

  // Declare using pair of x(DateTime) and y(value) entries.
  var series = ChartTimeSeries(
      {
        'A': [ [ DateTime(2020 , 03, 30) , 10 ] , [ DateTime(2020 , 03, 31) , 20 ] , [ DateTime(2020 , 04, 01) , 5 ] , [ DateTime(2020 , 04, 02) , -10 ] , [ DateTime(2020 , 04, 03) , 1 ] ] ,
        'B': [ [ DateTime(2020 , 03, 30) , 15 ] , [ DateTime(2020 , 03, 31) , 25 ] , [ DateTime(2020 , 04, 01) , 55 ] , [ DateTime(2020 , 04, 02) , 30 ] , [ DateTime(2020 , 04, 03) , -10 ] ] ,
        'C': [ [ 100 , DateTime(2020 , 03, 30) ] , [ DateTime(2020 , 03, 31) , 130 ] , [ DateTime(2020 , 04, 01) , 140 ] , [ DateTime(2020 , 04, 02) , -20 ] , [ DateTime(2020 , 04, 03) , -55 ] ] ,
      }
  ) ;

  series.title = 'Time Series Chart Example' ;
  series.xTitle = 'Months' ;
  series.yTitle = 'Count' ;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  var charEngine2 = ChartEngineChartJS() ;

  // Simultaneous load engines:
  await Future.wait( [ charEngine1.load() , charEngine2.load() ] ) ;

  charEngine1.renderTimeSeriesChart( querySelector('#apexcharts-time_series-output') , series ) ;
  charEngine2.renderTimeSeriesChart( querySelector('#chartjs-time_series-output') , series ) ;

}

Future createBarChart() async {

  var series = ChartSeries(
      ['Jan','Feb','Mar'],
      {
        'A': [10,20,5] ,
        'B': [15,25,55] ,
        'C': [100,130,140] ,
      }
  ) ;

  series.xTitle = 'Months' ;
  series.yTitle = 'Count' ;

  // Render the same ChartSeries using 2 engines:

  var charEngine1 = ChartEngineApexCharts() ;
  var charEngine2 = ChartEngineChartJS() ;

  // Simultaneous load engines:
  await Future.wait( [ charEngine1.load() , charEngine2.load() ] ) ;

  series.title = 'Bar Chart Example' ;
  charEngine1.renderBarChart( querySelector('#apexcharts-bar-output') , series ) ;
  charEngine2.renderBarChart( querySelector('#chartjs-bar-output') , series ) ;

  series.title = 'Horizontal Bar Chart Example' ;
  charEngine1.renderHorizontalBarChart( querySelector('#apexcharts-horizontal-bar-output') , series ) ;
  charEngine2.renderHorizontalBarChart( querySelector('#chartjs-horizontal-bar-output') , series ) ;

}


Future createGaugeChart() async {

  // Using Set: 1 value per category.
  // For Gauge needs to be in range of 0% to 100%.
  var set = ChartSet(
      {
        'A': 60 ,
        'B': 75 ,
        'C': 50 ,
      }
  ) ;

  set.title = 'Gauge Chart Example' ;

  var charEngine1 = ChartEngineApexCharts() ;
  var charEngine2 = ChartEngineChartJS() ;

  // Simultaneous load engines:
  await Future.wait( [ charEngine1.load() , charEngine2.load() ] ) ;

  charEngine1.renderGaugeChart( querySelector('#apexcharts-gauge-output') , set ) ;
  charEngine2.renderGaugeChart( querySelector('#chartjs-gauge-output') , set ) ;

}

