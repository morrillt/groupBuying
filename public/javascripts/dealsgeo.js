$.widget("ui.map", {
    _init: function() {
	var latlng = new google.maps.LatLng(40.79513, -73.96331);

	var myOptions = {
            zoom: 12,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	this.map = new google.maps.Map(document.getElementById("map_canvas"),
				       myOptions);

    },
    mark: function(lat,lng, title) {
    	var latlng = new google.maps.LatLng(lat,lng);
    	var marker = new google.maps.Marker({
    	    position: latlng,
    	    map: this.map, 
    	    title: title
    	});
    }
});

jQuery(document).ready(function($) {
    var $map= $("#map_canvas");
    $map.map();

    $("#deals-list li").each(function() {
    	var latlng= $(this).find(".at .latlng").text().split(",");
    	var title= $(this).find(".name").text();
    	var lat= parseFloat(latlng[0]);
    	var lng= parseFloat(latlng[1]);
    	$map.map("mark",lat,lng,title);
    });
});