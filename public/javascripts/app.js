/* Made by Mathias Bynens <http://mathiasbynens.be/> */
function number_format(a, b, c, d) {
    a = Math.round(a * Math.pow(10, b)) / Math.pow(10, b);
    e = a + '';
    f = e.split('.');
    if (!f[0]) {
	f[0] = '0';
    }
    if (!f[1]) {
	f[1] = '';
    }
    if (f[1].length < b) {
	g = f[1];
	for (i=f[1].length + 1; i <= b; i++) {
	    g += '0';
	}
	f[1] = g;
    }
    if(d != '' && f[0].length > 3) {
	h = f[0];
	f[0] = '';
	for(j = 3; j < h.length; j+=3) {
	    i = h.slice(h.length - j, h.length - j + 3);
	    f[0] = d + i +  f[0] + '';
	}
	j = h.substr(0, (h.length % 3 == 0) ? 3 : (h.length % 3));
	f[0] = j + f[0];
    }
    c = (b <= 0) ? '' : c;
    return f[0];// + c + f[1];
}

$.widget("ui.counter", {
    _init: function() {
	var cnt = 0;
        var counter;
	$.get("/sites/coupons_count", function(data) {
	    cnt= data.coupons_count;
	    counter = setInterval(function() {
		$('#coupons-counter .count').html(number_format(cnt, 2, '', ','));
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
		}],
		min:0
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
		labels: {
		    rotation: -45
		}
	    },
	    series: self.data.series
	});	
    }
});

function show_stats(i) {
	$(".variation-table").hide();
	$("#stats_" + i).show();
}

$(document).ready(function() {
    $("#coupons-counter").counter();
		if (window.location.pathname != '/') {
	    chart_data.series= chart_data.series.slice(0,5);
		}
    try {
			$("#sites #chart").chart({data:chart_data});
			$("#site-stats #chart").chart({data:chart_data});
    } catch (err) {
			
    }	

    show_stats(0);
});