function loadTable(){
	$("#ajaxTable").load("/admin/"+model+"/table");
}

function loadingTimer(){
    $("#ajax_loading_div")
	.bind("ajaxSend", function(){
	    $(this).show();
	})
	.bind("ajaxComplete", function(){
	    $(this).hide();
	});
}

function searchTable(searchTerm){
loadingTimer();
	$("#ajaxTable").load("/admin/"+model+"/table?search=" + encodeURI(searchTerm));
}

function gotoStart(start){
loadingTimer();
var search_text = '';
if($("#searchText").val()!='Search'){search_text=$("#searchText").val()}
	$("#ajaxTable").load("/admin/"+model+"/table?start=" + start + "&search=" + search_text);
}

function sortTable(order_by,direction){
loadingTimer();
var search_text = '';
if($("#searchText").val()!='Search'){search_text=$("#searchText").val()}
	$("#ajaxTable").load("/admin/"+model+"/table?start=0&search=" + search_text + "&order_by=" + order_by + "&direction=" + direction);
	$("#" + order_by).attr("src","img' + '/javascripts/thirdparty/MyAjax/arrow_down.gif");
}


this.label2value = function(){	
	var inactive = "inactive";
	var active = "active";
	var focused = "focused";
	
	$("label").each(function(){		
		obj = document.getElementById($(this).attr("for"));
		if(($(obj).attr("type") == "text") || (obj.tagName.toLowerCase() == "textarea")){			
			$(obj).addClass(inactive);			
			var text = $(this).text();
			$(this).css("display","none");			
			$(obj).val(text);
			$(obj).focus(function(){	
				$(this).addClass(focused);
				$(this).removeClass(inactive);
				$(this).removeClass(active);								  
				if($(this).val() == text) $(this).val("");
			});	
			$(obj).blur(function(){	
				$(this).removeClass(focused);													 
				if($(this).val() == "") {
					$(this).val(text);
					$(this).addClass(inactive);
				} else {
					$(this).addClass(active);		
				};				
			});				
		};	
	});		
};

var t = document.getElementsByTagName("tr");
for(var i=0;i<t.length;i++) {
  var ocn = t[i].className;
  t[i].onmouseover = function() { t[i].className = "hovered" };
  t[i].onmouseout = function() { t[i].className = ocn };
}