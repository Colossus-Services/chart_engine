
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('ApexCharts') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'ApexCharts'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ApexCharts__ = {}, global.ApexCharts ));
}(this, (function (exports, moduleApexCharts)
{ 'use strict';

    const ApexCharts = moduleApexCharts.default ;

    exports.renderLine = function (elem, title, xTitle, yTitle, xLabels, series, colors, fillLines, straightLines) {

        const datasets = [] ;
        const datasetsColors = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                type: fillLines ? 'area' : 'line' ,
                name: key,
                data: val
            };

            datasets.push( entry ) ;
            datasetsColors.push( color ) ;
        }

        const options = {
            chart: {
                type: 'line'
            },
            series: datasets,
            xaxis: {
                categories: xLabels ,
                title: {

                }
            },
            yaxis: {
                title: {

                }
            },
            colors: datasetsColors,
            stroke: {
                curve: straightLines ? 'straight' : 'smooth',
            }
        }

        if (xTitle != null) {
            options['xaxis']['title']['text'] = xTitle ;
        }

        if (yTitle != null) {
            options['yaxis']['title']['text'] = yTitle ;
        }

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };

})));
