
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('ApexCharts') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'ApexCharts'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ApexCharts__ = {}, global.ApexCharts ));
}(this, (function (exports, moduleApexCharts)
{ 'use strict';

    const ApexCharts = moduleApexCharts.default ;

    exports.configure = function (type, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, datasets, verticalLines, datasetsColors, straightLines, horizontalBar, xMin, xMax, yMin, yMax, timed) {

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
            },
            legend: {

            }
        }

        const xaxis = options['xaxis'];
        const yaxis = options['yaxis'];

        if (verticalLines != null) {
            options['annotations'] = {
                xaxis: verticalLines
            };
        }

        if (xLabels != null) {
            xaxis['categories'] = xLabels ;
        }

        if (xAxisMinMax != null) {
            if (xAxisMinMax[0] != null) xMin = xAxisMinMax[0];
            if (xAxisMinMax[1] != null) xMax = xAxisMinMax[1];
        }

        if (yAxisMinMax != null) {
            if (yAxisMinMax[0] != null) yMin = yAxisMinMax[0];
            if (yAxisMinMax[1] != null) yMax = yAxisMinMax[1];
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

        if (timed != null && timed) {
            xaxis['type'] = 'datetime' ;
        }

        return options ;
    };

    exports.renderLine = function (elem, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, fillLines, straightLines) {
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

        const options = this.configure('line', title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, datasets, verticalLines, datasetsColors, straightLines) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderTimeSeries = function (elem, title, xTitle, yTitle, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, fillLines, straightLines) {
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

        const options = this.configure('line', title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, verticalLines, datasetsColors, straightLines, null, null, null, null, null, true) ;

        // Fix X axis title position to not colide with axis date ticks:
        if (xTitle != null) {
            options['xaxis']['title']['offsetY'] = 8;
            options['legend']['offsetY'] = 4;
        }

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderBar = function (horizontal, elem, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, series, colors) {
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

        const options = this.configure('bar', title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, datasets, null, datasetsColors, false, horizontal) ;

        this.configure(options, title, xTitle, yTitle) ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderGauge = function (elem, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, series, colors) {
        const datasets = [] ;
        const datasetsColors = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;
            datasets.push( val ) ;
            datasetsColors.push( color ) ;
        }

        const options = this.configure('radialBar', title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, null, datasetsColors, false, false) ;

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
                    },
                    total: {
                        show: true,
                        label: '',
                        color: '#000000',
                        fontWeight: 600,
                        formatter: function (w) {
                            const percentUsed = w.globals.seriesTotals.reduce((a, b) => {
                                return a + b
                            }, 0);
                            const percentTotal = w.globals.series.length;
                            const centerPercent = Math.floor( percentUsed / percentTotal ) ;
                            return centerPercent + '%'
                        }
                    }
                }
            }
        } ;

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };


    exports.renderScatter = function (elem, title, xTitle, yTitle, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, yMin, yMax, timed) {
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

        const options = this.configure('scatter', title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, verticalLines, datasetsColors, null, null, null, null, yMin, yMax, timed) ;

        // Fix X axis title position to not colide with axis date ticks:
        if (xTitle != null) {
            options['xaxis']['title']['offsetY'] = 8;
            options['legend']['offsetY'] = 4;
        }

        const chart = new ApexCharts(elem, options);

        chart.render();

        return chart ;
    };

})));
