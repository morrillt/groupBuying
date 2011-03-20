$.widget("ui.counter", {
    _init: function() {
	var cnt = 0;
        var counter;
	$.get("/sites/coupons_count", function(data) {
	    cnt= data.coupons_count;
	    counter = setInterval(function() {
		$('#coupons-counter .count').html(cnt);
		cnt++;
            }, 500);
	});
    }
});

$.widget("ui.chart", {
    _init: function() {
	var $el= this.element;
	var self= this;
	this.data= this.options.data;
	this.chart = new Highcharts.Chart({
	    chart: {
		renderTo: 'chart',
		defaultSeriesType: 'line',
		marginBottom: 25
	    },
	    title: {
		text: "Revenue per hour"
	    },
	    yAxis: {
		title: {
		    text: 'new revenue ($)'
		},
		plotLines: [{
		    value: 0,
		    width: 1,
		    color: '#808080'
		}]
	    },
	    tooltip: {
		formatter: function() {
		    return '<b>' + this.x + '</b>' + this.y + '$';
		}
	    },
	    legend: {
		layout: 'vertical',
		align: 'right',
		verticalAlign: 'top',
		x: -10,
		y: 100,
		borderWidth: 0
	    },
	    
	    xAxis: {
		categories: self.data.categories,
		// ["06:00","08:00","10:00","12:00","14:00","16:00","18:00","20:00","22:00","00:00"],
		labels: {
		    rotation: -45
		}
	    },
	    series: self.data.series
	    // [
	    // 	{name: 'Home Run', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}, {name: 'Living Social', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}, {name: 'Open Table', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}, {name: 'Kgb Deals', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}, {name: 'Groupon', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}, {name: 'Travel Zoo', data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}
	    // ]
	});	
    }
});

$(document).ready(function() {
    $("#coupons-counter").counter();
    $("#sites #chart").chart({data:chart_data});
    $("#site-stats #chart").chart({data:chart_data});
});