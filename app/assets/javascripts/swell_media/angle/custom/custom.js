// Custom jQuery
// ----------------------------------- 


(function(window, document, $, undefined){

  $(function(){

    // document ready

    var options = {
                    series: {
                        lines: {
                            show: true,
                            fill: 0.01
                        },
                        points: {
                            show: true,
                            radius: 2
                        }
                    },
                    grid: {
                        borderColor: '#eee',
                        borderWidth: 1,
                        hoverable: true,
                        backgroundColor: '#fcfcfc'
                    },
                    tooltip: true,
                    tooltipOpts: {
                        content: function (label, x, y) { return x + ' : ' + y; }
                    },
                    xaxis: {
                        tickColor: '#eee',
                        mode: 'categories'
                    },
                    yaxis: {
                        // position: 'right' or 'left'
                        tickColor: '#eee'
                    },
                    shadowSize: 0
                };


    var $stats_chart = $('#stats_chart');
    var $chart_data = $.parseJSON( $('#chart_data').text() );

    if( $stats_chart.length ){
    	$.plot( $stats_chart, $chart_data, options );
    }

  });

})(window, document, window.jQuery);