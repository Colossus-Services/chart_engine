
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('ApexCharts') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'ApexCharts'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ApexCharts__ = {}, global.ApexCharts ));
}(this, (function (exports, moduleApexCharts)
{ 'use strict';

    const ApexCharts = moduleApexCharts.default ;

    exports.configure = function (type, title, xTitle, yTitle, xLabels, datasets, datasetsColors, straightLines, horizontal) {

        const options = {
            chart: {
                type: type
            },
            series: datasets,
            title: {
            },
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

        if (horizontal) {
            options['plotOptions'] = {
                bar: {
                    horizontal: true,
                }
            };
        }

        if (title != null) {
            options['title']['text'] = title ;
        }

        if (xTitle != null) {
            options['xaxis']['title']['text'] = xTitle ;
        }

        if (yTitle != null) {
            options['yaxis']['title']['text'] = yTitle ;
        }

        return options ;
    };

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

        const options = this.configure('line', title, xTitle, yTitle, xLabels, datasets, datasetsColors, straightLines, false) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderBar = function (horizontal, elem, title, xTitle, yTitle, xLabels, series, colors) {
        const datasets = [] ;
        const datasetsColors = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                name: key,
                data: val
            };

            datasets.push( entry ) ;
            datasetsColors.push( color ) ;
        }

        const options = this.configure('bar', title, xTitle, yTitle, xLabels, datasets, datasetsColors, false, horizontal) ;

        this.configure(options, title, xTitle, yTitle) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };

})));
