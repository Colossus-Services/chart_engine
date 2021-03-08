
(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports, require('chartjs'), global) :
        typeof define === 'function' && define.amd ? define(['exports', 'chartjs'], factory) :
            (global = global || self, factory(global.__ChartEngine_Wrapper_ChartJS__ = {}, global.Chart , global ));
}(this, (function (exports, Chart, global)
{ 'use strict';

    global = global || self ;
    const moment = global != null ? global.moment : null ;

    if ( moment == null ) {
        const FORMATS = {
            datetime: 'MMM D, YYYY, h:mm:ss a',
            millisecond: 'h:mm:ss.SSS a',
            second: 'h:mm:ss a',
            minute: 'h:mm a',
            hour: 'hA',
            day: 'MMM D',
            week: 'MMM D',
            month: 'MMM YYYY',
            quarter: '[Q]Q YYYY',
            year: 'YYYY'
        };

        Chart._adapters._date.override({
            _id: 'chart_engine', // DEBUG ONLY

            formats: function () {
                return FORMATS;
            },

            parse: function (value, format) {
                return exports._DateAdapter__parse(value, format);
            },

            format: function (time, format) {
                return exports._DateAdapter__format(time, format);
            },

            add: function (time, amount, unit) {
                return exports._DateAdapter__add(time, amount, unit);
            },

            diff: function (max, min, unit) {
                return exports._DateAdapter__diff(max, min, unit);
            },

            startOf: function (time, unit, weekday) {
                return exports._DateAdapter__startOf(time, unit, weekday);
            },

            endOf: function (time, unit) {
                return exports._DateAdapter__endOf(time, unit);
            },

            _create: function (time) {
                return exports._DateAdapter__create(time);
            },
        });
    }

    const verticalLinePlugin = {
        afterDatasetsDraw: function (chart, easing) {
            if (chart.config == null) return ;
            let verticalLines = chart.config.verticalLines ;
            if (verticalLines != null) {
                for ( let [idx, conf] of  Object.entries(verticalLines) ) {
                    let label = conf['label'] ;
                    let color = conf['color'] ;
                    let yPos = conf['y'] ;
                    let textAlign = conf['textAlign'] ;
                    this.drawVerticalLine(chart, idx, label, color, yPos, textAlign);
                }
            }
        },

        drawVerticalLine: function (chart, valueIndex, label, color, yPos, textAlign) {
            const meta = chart.getDatasetMeta(0);
            const data = meta.data;
            const scale = chart.scales['y-axis-0'];

            const top = scale.top;
            const bottom = scale.bottom;
            const x = data[valueIndex]._model.x;
            const y = ((bottom - top) * yPos) + top;

            const context = chart.chart.ctx;
            context.beginPath();
            context.strokeStyle = color;
            context.moveTo(x, top);
            context.lineTo(x, bottom);
            context.stroke();

            context.fillStyle = color;
            context.textAlign = textAlign;
            context.fillText(label, x, y);
        }
    };

    Chart.plugins.register(verticalLinePlugin);

    exports.configure = function (type, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, datasets, verticalLines, showLegend, showGridLines, showXAxis, showYAxis, timeSeries, onClickCallback) {

        const config = {
            type: type,
            data: {
                datasets: datasets
            },
            options: {
                responsive: true,
                title: {
                    display: title != null ,
                    text: title
                },
                legend: {
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

        const configData = config['data'];
        let configOptions = config['options'];
        const configScales = configOptions['scales'];

        if (verticalLines != null) {
            config['verticalLines'] = verticalLines ;
        }

        if (onClickCallback != null) {
            configOptions['onClick'] = function (evt, items) {
                const xItems = [] ;
                const yItems = [] ;

                if (evt != null) {
                    const chart = this;

                    const x = evt.offsetX ;
                    const y = evt.offsetY ;

                    if (x != null) {
                        for ( let [scaleKey, scale] of  Object.entries(chart.scales) ) {
                            if (scaleKey.startsWith('x-axis-')) {
                                let val = scale.getValueForPixel(x);
                                xItems.push(val);
                            }
                        }
                    }

                    if (y != null) {
                        for ( let [scaleKey, scale] of  Object.entries(chart.scales) ) {
                            if (scaleKey.startsWith('y-axis-')) {
                                let val = scale.getValueForPixel(y);
                                yItems.push(val);
                            }
                        }
                    }
                }

                const activeItems = [] ;

                if (items != null) {
                    for (let e of items) {
                        const chart = e._chart;
                        const datasetIndex = e._datasetIndex;
                        const index = e._index;
                        if (chart != null && index != null && datasetIndex != null) {
                            const dataset = chart.data.datasets[datasetIndex];
                            const value = dataset.data[index];
                            const label = chart.data.labels[index];
                            activeItems.push({datasetIndex: datasetIndex, index: index, value: value, label: label});
                        }
                    }
                }

                onClickCallback( activeItems , xItems, yItems ) ;
            };
        }

        if (xLabels != null) {
            configData['labels'] = xLabels ;
        }

        if ( showLegend != null ) {
            configOptions['legend']['display'] = showLegend ;
        }

        if ( showGridLines != null ) {
            configScales['xAxes'].forEach(
                e => e['gridLines'] = { display: showGridLines }
            );

            configScales['yAxes'].forEach(
                e => e['gridLines'] = { display: showGridLines }
            );
        }

        if (showXAxis != null) {
            configScales['xAxes'].forEach( e => e['display'] = showXAxis);
        }

        if (showYAxis != null) {
            configScales['yAxes'].forEach( e => e['display'] = showYAxis);
        }

        if (yAxisMinMax != null) {
            let ticks = {} ;
            if (yAxisMinMax[0] != null) ticks['suggestedMin'] = yAxisMinMax[0];
            if (yAxisMinMax[1] != null) ticks['suggestedMax'] = yAxisMinMax[1];
            configScales['yAxes'].forEach( e => e['ticks'] = ticks);
        }

        if (timeSeries != null && timeSeries) {
            configScales['xAxes'].forEach( (e) => {
                e['type'] = 'time';
                e['time'] = {
                    displayFormats: {
                        'millisecond': 'H:mm:ss.SSS',
                        'second': 'H:mm:ss',
                        'minute': 'H:mm',
                        'hour': 'MMM D H:mm',
                        'day': 'MMM D',
                        'week': 'MMM D',
                        'month': 'MMM YYYY',
                        'quarter': '[Q]Q YYYY',
                        'year': 'YYYY',
                    }
                };
            });

            if (xAxisMinMax != null) {
                if (xAxisMinMax[0] != null) {
                    configScales['xAxes'].forEach( e => e['time']['min'] = xAxisMinMax[0]);
                }
                if (xAxisMinMax[1] != null) {
                    configScales['xAxes'].forEach( e => e['time']['max'] = xAxisMinMax[1]+1);
                }
            }
        }
        else {
            if (xAxisMinMax != null) {
                let ticks = {} ;
                if (xAxisMinMax[0] != null) ticks['suggestedMin'] = xAxisMinMax[0];
                if (xAxisMinMax[1] != null) ticks['suggestedMax'] = xAxisMinMax[1];
                configScales['xAxes'].forEach( e => e['ticks'] = ticks);
            }
        }

        return config ;
    };

    exports.addData_label_data = function (chart, label, datasetIndex, data) {
        chart.data.labels.push(label);
        chart.data.datasets[datasetIndex].data.push(data);
    }

    exports.addData_date_value = function (chart, date, datasetIndex, value) {
        chart.data.datasets[datasetIndex].data.push(value);
    }

    exports.addData_tohlc = function (chart, datasetIndex, ohlcValue, timeTolerance, preserveTimeOfOverwrittenValue) {
        const datasets = chart.data.datasets;
        let dataset ;

        if (typeof datasetIndex == 'string' || datasetIndex instanceof String) {
            dataset = this._find(datasets, e => e['label'] === datasetIndex);
        }
        else {
            dataset = datasets[datasetIndex];
        }

        if (dataset == null) return null;

        const data = dataset.data;

        const t = ohlcValue['t'];

        this._sortTOHLC(data) ;

        let idx ;

        if (timeTolerance != null) {
            idx = this._binarySearchComparator(data, e => e['t'], 0, data.length-1, t, (a,b) => {
                let diff = a-b ;
                if (diff < 0) diff = -diff;
                if (diff < timeTolerance) return 0 ;
                return a < b ? -1 : (a > b ? 1 : 0);
            }) ;
        }
        else {
            idx = this._binarySearch(data, e => e['t'], 0, data.length-1, t) ;
        }

        if (idx >= 0) {
            if (preserveTimeOfOverwrittenValue) {
                const prevT = data[idx]['t'];
                if (prevT != null) {
                    ohlcValue['t'] = prevT;
                }
            }

            data.splice(idx, 1, ohlcValue);
        }
        else {
            const insertIdx = (-idx)-1;

            if (insertIdx < data.length) {
                data.splice(insertIdx, 0, ohlcValue);
            }
            else {
                data.push(ohlcValue);
            }
        }
    }

    exports._binarySearchComparator = function (a, getter, fromIndex, toIndex, key, comparator) {
        let low = fromIndex;
        let high = toIndex - 1;

        while (low <= high) {
            let mid = (low + high) >>> 1;
            let midElem = a[mid];
            let midVal = getter(midElem);

            let cmp = comparator(midVal, key);

            if (cmp < 0)
                low = mid + 1;
            else if (cmp > 0)
                high = mid - 1;
            else
                return mid; // key found
        }

        return -(low + 1);  // key not found.
    }

    exports._binarySearch = function (a, getter, fromIndex, toIndex, key) {
        let low = fromIndex;
        let high = toIndex - 1;

        while (low <= high) {
            let mid = (low + high) >>> 1;
            let midElem = a[mid];
            let midVal = getter(midElem);

            if (midVal < key)
                low = mid + 1;
            else if (midVal > key)
                high = mid - 1;
            else
                return mid; // key found
        }

        return -(low + 1);  // key not found.
    }

    exports._sortTOHLC = function (a, matcher) {
        a.sort((a, b) => {
            const t1 = a['t'];
            const t2 = b['t'];
            return t1 < t2 ? -1 : (t1 > t2 ? 1 : 0);
        });
    }

    exports._findIndexOf = function (a, matcher) {
        if (a == null || a.length === 0) return -1 ;
        const lng = a.length ;
        for (let i = 0 ; i < lng; i++) {
            const val = a[i] ;
            if ( matcher(val) ) {
                return i ;
            }
        }
        return -1;
    }

    exports._find = function (a, matcher) {
        if (a == null || a.length === 0) return null ;
        const lng = a.length ;
        for (let i = 0 ; i < lng; i++) {
            const val = a[i] ;
            if ( matcher(val) ) {
                return val ;
            }
        }
        return null;
    }

    exports.renderLine = function (canvas, title, xTitle, yTitle, xLabels, xAxisMinMAx, yAxisMinMax, series, verticalLines, colors, fillLines, straightLines, steppedLines, onClickCallback) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;
        const lineTension = straightLines ? 0.0 : 0.4 ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                label: key,
                data: val,
                fill: fillLines,
                borderColor: color,
                backgroundColor: color,
                lineTension: lineTension
            };

            if (steppedLines != null && steppedLines) {
                entry['steppedLine'] = true ;
            }

            datasets.push( entry ) ;
        }

        const config = this.configure('line', title, xTitle, yTitle, xLabels, xAxisMinMAx, yAxisMinMax, datasets, verticalLines, null,null,null,null, null, onClickCallback) ;

        const chart = new Chart(ctx, config);

        return chart ;
    };


    exports.renderTimeSeries = function (canvas, title, xTitle, yTitle, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, fillLines, straightLines, steppedLines, onClickCallback) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;
        const lineTension = straightLines ? 0.0 : 0.4 ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                label: key,
                data: val,
                fill: fillLines,
                borderColor: color,
                backgroundColor: color,
                lineTension: lineTension
            };

            if (steppedLines != null && steppedLines) {
                entry['steppedLine'] = true ;
            }

            datasets.push( entry ) ;
        }

        const config = this.configure('line', title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, verticalLines, null,null,null,null, true, onClickCallback) ;

        const chart = new Chart(ctx, config);

        return chart ;
    };

    exports.renderBar = function (horizontal, canvas, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, series, colors) {
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

        const config = this.configure(type, title, xTitle, yTitle, xLabels, xAxisMinMax, yAxisMinMax, datasets) ;

        const chart = new Chart(ctx, config);

        return chart ;
    };


    exports.renderGauge = function (canvas, title, xTitle, yTitle, xLabels, series, colors, disabledColors, onClickCallback) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;

        let usedPercent = 0 ;
        let totalPercent = 0 ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;
            let disabledColor = disabledColors[key] ;

            usedPercent += val ;
            totalPercent += 100 ;

            const entry = {
                label: key,
                data: [val, 100-val],
                borderColor: ['rgba(0,0,0, 0)', 'rgba(0,0,0, 0)'],
                backgroundColor: [color, disabledColor],
            };

            datasets.push( entry ) ;
        }

        let centerPercent = Math.floor((usedPercent/totalPercent) * 100 ) ;

        const type = 'doughnut' ;

        const config = this.configure(type, title, xTitle, yTitle, xLabels, null, null, datasets, null, false, false, false, false, null, onClickCallback) ;

        const configOptions = config['options'];

        configOptions['circumference'] = Math.PI ;
        configOptions['rotation'] = Math.PI ;
        configOptions['cutoutPercentage'] = 70 ;

        configOptions['tooltips'] = {
            callbacks: {
                label: function(tooltipItem, data) {
                    const label = data.datasets[tooltipItem.datasetIndex].label;
                    const val = data.datasets[tooltipItem.datasetIndex]['data'][tooltipItem.index] ;

                    if (tooltipItem.index === 0) {
                        return label+': '+ val +'%' ;
                    }
                    else {
                        return val +'%' ;
                    }
                }
            }
        };


        config['plugins'] = [{
            id: 'my-plugin',
            beforeDraw: function (chart, option) {
                const theCenterText = centerPercent+'%';
                const canvasBounds = canvas.getBoundingClientRect();
                const fontSz = Math.floor( canvasBounds.height * 0.15 ) ;
                chart.ctx.textBaseline = 'middle';
                chart.ctx.textAlign = 'center';
                chart.ctx.font = fontSz+'px Arial';
                chart.ctx.fillStyle = '#000000';
                chart.ctx.fillText(theCenterText, canvasBounds.width/2, canvasBounds.height*0.79 )
            }
        }];

        const chart = new Chart(ctx, config);

        return chart ;
    };


    exports.renderScatter = function (canvas, title, xTitle, yTitle, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, timed, onClickCallback) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;

        for ( let [key, val] of  Object.entries(series) ) {
            let color = colors[key] ;

            const entry = {
                label: key,
                data: val,
                borderColor: color,
                backgroundColor: color,
                pointRadius: 5,
                pointHoverRadius: 8
            };

            datasets.push( entry ) ;
        }

        const config = this.configure('scatter', title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, verticalLines, null,null,null,null, timed, onClickCallback) ;

        const configOptions = config['options'];

        configOptions['tooltips'] = {
            callbacks: {
                label: function(tooltipItem, data) {
                    let label = data.datasets[tooltipItem.datasetIndex].label;
                    return ' '+ tooltipItem.yLabel +' ( '+ tooltipItem.xLabel +' ) [ '+ label +' ]';
                }
            }
        };

        const chart = new Chart(ctx, config);

        return chart ;
    };

    exports.renderFinancial = function (canvas, title, xTitle, yTitle, xAxisMinMax, yAxisMinMax, series, verticalLines, colors, colorsUp, colorsDown, colorsUnchanged, ohlc, onClickCallback) {
        const ctx = canvas.getContext('2d');

        const datasets = [] ;

        for ( let [key, values] of  Object.entries(series) ) {
            let color = colors[key] ;
            let colorUp = colorsUp[key] ;
            let colorDown = colorsDown[key] ;
            let colorUnchanged = colorsUnchanged[key] ;

            const entry = {
                label: key,
                data: values,
                borderColor: color,
                backgroundColor: color,

                color: {
                    up: colorUp,
                    down: colorDown,
                    unchanged: colorUnchanged,
                }
            };

            datasets.push( entry ) ;
        }

        const type = ohlc ? 'ohlc' : 'candlestick' ;

        const config = this.configure(type, title, xTitle, yTitle, null, xAxisMinMax, yAxisMinMax, datasets, verticalLines, null, null, null, null, true, onClickCallback) ;

        const chart = new Chart(ctx, config);

        return chart ;
    };

})));
