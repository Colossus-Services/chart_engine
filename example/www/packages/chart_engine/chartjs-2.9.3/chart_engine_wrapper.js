
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('chartjs') ) :
        typeof define === 'function' && define.amd ? define(['exports', 'chartjs'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ChartJS__ = {}, global.Chart ));
}(this, (function (exports, Chart)
{ 'use strict';

    exports.configure = function (type, title, xTitle, yTitle, xLabels, datasets) {

        const config = {
            type: type,
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

        return config ;
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

        const config = this.configure('line', title, xTitle, yTitle, xLabels, datasets) ;

        const chart = new Chart(ctx, config);

        return chart ;
    };

    exports.renderBar = function (horizontal, canvas, title, xTitle, yTitle, xLabels, series, colors) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                label: key,
                data: val,
                borderColor: color,
                backgroundColor: color,
            };

            datasets.push( entry ) ;
        }

        const type = horizontal ? 'horizontalBar' : 'bar' ;

        const config = this.configure(type, title, xTitle, yTitle, xLabels, datasets) ;

        console.log('>>>>>>>> '+ type +' ; '+ horizontal) ;
        console.log(config);

        const chart = new Chart(ctx, config);

        return chart ;
    };

})));
