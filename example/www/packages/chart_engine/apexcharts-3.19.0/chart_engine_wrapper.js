
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('ApexCharts') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'ApexCharts'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ApexCharts__ = {}, global.ApexCharts ));
}(this, (function (exports, moduleApexCharts)
{ 'use strict';

    const ApexCharts = moduleApexCharts.default ;

    exports.configure = function (type, title, xTitle, yTitle, xLabels, datasets, datasetsColors, straightLines, horizontalBar, xMin, xMax, yMin, yMax) {

        const options = {
            chart: {
                type: type
            },
            series: datasets,
            title: {
            },
            xaxis: {
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

        const xaxis = options['xaxis'];
        const yaxis = options['yaxis'];

        if (xLabels != null) {
            xaxis['categories'] = xLabels ;
        }

        if (xMin != null) {
            xaxis['min'] = xMin ;
        }

        if (xMax != null) {
            xaxis['max'] = xMax ;
        }

        if (yMin != null) {
            yaxis['min'] = yMin ;
        }

        if (yMax != null) {
            yaxis['max'] = yMax ;
        }

        if (horizontalBar) {
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
            xaxis['title']['text'] = xTitle ;
        }

        if (yTitle != null) {
            yaxis['title']['text'] = yTitle ;
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

        const options = this.configure('line', title, xTitle, yTitle, xLabels, datasets, datasetsColors, straightLines) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderTimeSeries = function (elem, title, xTitle, yTitle, series, colors, fillLines, straightLines) {
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

        xTitle = null ;

        const options = this.configure('line', title, xTitle, yTitle, null, datasets, datasetsColors, straightLines) ;

        options['xaxis']['type'] = 'datetime' ;

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


    exports.renderGauge = function (elem, title, xTitle, yTitle, xLabels, series, colors) {
        const datasets = [] ;
        const datasetsColors = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;
            datasets.push( val ) ;
            datasetsColors.push( color ) ;
        }

        const options = this.configure('radialBar', title, xTitle, yTitle, null, datasets, datasetsColors, false, false) ;

        this.configure(options, title, xTitle, yTitle) ;

        options['labels'] = xLabels ;

        options['plotOptions'] = {
            radialBar: {
                startAngle: -90,
                endAngle: 90,
                dataLabels: {
                    name: {
                        offsetY: -45,
                        show: true,
                    },
                    value: {
                        offsetY: -25,
                        fontSize: "30px",
                        show: true
                    }
                }
            }
        } ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderScatter = function (elem, title, xTitle, yTitle, series, colors, yMin, yMax) {
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

        xTitle = null ;

        const options = this.configure('scatter', title, xTitle, yTitle, null, datasets, datasetsColors, null, null, null, null, yMin, yMax) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };

})));
