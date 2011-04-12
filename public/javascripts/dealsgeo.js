$.widget("ui.map", {
    _init: function() {
	var latlng = new google.maps.LatLng(40.79513, -100.96331);
	// var latlng = new google.maps.LatLng(6.2604225,-75.5902047);
	var myOptions = {
            zoom: 4,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	this.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	this.info_window= new google.maps.InfoWindow({
	    content: document.getElementById("info-window")
	});

	// this.element.bind('open_deal', function(e, id) {
	//     this.open_deal(id);
	// });
    },
    mark: function(id, lat,lng, title) {
	var self= this;
    	var latlng = new google.maps.LatLng(parseFloat(lat),parseFloat(lng));
    	var marker = new google.maps.Marker({
    	    position: latlng,
    	    map: this.map, 
    	    title: title
    	});
	// google.maps.event.addListener(marker, 'click', function() {
	//     self.element.trigger("open_deal", id);
	// });
    },
    open_deal: function(id) {
	console.log(id);
	// var $deal= $("[id="+id+"]");
	// var thumb= $deal.find(".thumb image").attr("src");
	// $("#info-window").find(".site-thumb img").attr("src", thumb);
    }
});

jQuery(document).ready(function($) {
    var $map= $("#map_canvas");
    $map.map();

    $("#deals-list li").each(function() {
    	var latlng= $(this).find(".at .latlng").text().split(",");
    	var title= $(this).find(".name").text();
	var id= $(this).attr("id");
    	var lat= parseFloat(latlng[0]);
    	var lng= parseFloat(latlng[1]);
   	$map.map("mark",id,lat,lng,title);
    });
});