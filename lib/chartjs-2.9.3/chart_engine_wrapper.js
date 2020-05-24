
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('chartjs') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'chartjs'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ChartJS__ = {}, global.chartjs ));
}(this, (function (exports, Chart)
{ 'use strict';


    exports.chartColors = {
        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(201, 203, 207)'
    };

    exports.renderLine = function (canvas, title, xTitle, yTitle, xLabels, series, colors, fillLines, straightLines) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                label: key,
                data: val,
                fill: fillLines,
                borderColor: color,
                backgroundColor: color,
                lineTension: straightLines ? 0.0 : 0.4,
            };

            datasets.push( entry ) ;
        }

        const config = {
            type: 'line',
            data: {
                labels: xLabels,
                datasets: datasets
            },
            options: {
                responsive: true,
                title: {
                    display: title != null ,
                    text: title
                },
                scales: {
                    xAxes: [{
                        display: true,
                        scaleLabel: {
                            display: xTitle != null,
                            labelString: xTitle
                        }
                    }],
                    yAxes: [{
                        display: true,
                        scaleLabel: {
                            display: yTitle != null,
                            labelString: yTitle
                        }
                    }]
                }
            }
        };

        const chart = new Chart(ctx, config);

        return chart ;
    };

})));
