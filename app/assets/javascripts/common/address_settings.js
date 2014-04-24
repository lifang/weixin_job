function new_addre_button(){
   // $(".second_bg").show();
   tab_function($(".new_address"));
}

function address_search_city(obj,company_id,type){
    var province_id = $(obj).find("input[type=text]").val();
    $.ajax({
        type: "get",
        dataType: "json",
        url: "/companies/"+company_id+"/address_settings/search_citties",
        data: {
            pro_id : province_id
        },
        success: function(data){
            if(data.cities.length > 0){
                if(type==0){
                    $("#new_address_select_city").empty();
                    $("#new_address_select_city").append("<li>----<input name type='text' value='0'></li>")
                    $.each(data.cities, function(key,value){
                        $("#new_address_select_city").append("<li>"+value.name+"<input name type='text' value='"+value.id+"'></li>");
                    })
                    
                }else{
                    $("#edit_address_select_city").empty();
                    $("#new_address_city").html("<span>----</span><input name type='text' value='0'>");
                    $.each(data.cities, function(key,value){
                        $("#edit_address_select_city").append("<li>"+value.name+"<input name type='text' value='"+value.id+"'></li>");
                    })
                }
            }else{
                if(type==0){
                    $("#new_address_select_city").empty();
                    $("#new_address_select_city").html("<option value='0'>当前省份无城市</option>");
                }else{
                    $("#edit_address_select_city").empty();
                    $("#edit_address_select_city").html("<option value='0'>当前省份无城市</option>");
                }
                
            }
            select_init();
        },
        error: function(data){
            tishi_alert("数据错误!");
        }
    })
}

function select_init(){
	$(".select_tag").click(function() {
		//$(this).parent(".select_box").find("ul").toggle();
                $(this).parent(".select_box").find("ul").show();
	});
	$(".select_box ul li").click(function() {
		$(this).addClass("hover").siblings().removeClass("hover");
		var text = $(this).html();
		var $val = $(this).find("input").val();
		$(this).parents(".select_box").find(".select_tag span").html(text);
		$(this).parents(".select_box").find("input.tag_input").val($val);
		$(this).parents(".select_box").find("ul").hide();
	});

	$(document).bind('click', function(e) {
		var $clicked = $(e.target);
		if (! $clicked.parents().hasClass("select_box"))
		$(".select_box ul").hide();

	});

}


function address_valid(obj,type){    
    if(type==0){
        var addre = $.trim($(obj).parents("form").find("input[name='new_addre']").first().val());
        var city = $("#new_address_city").find("input[type=text]");
        $(city).attr("name","new_address_select_city");
        var city_id = $.trim($(city).val());
    }else{
        var addre = $.trim($(obj).parents("form").find("input[name='edit_addre']").first().val());
        var city = $("#new_address_city").find("input[type=text]");
        $(city).attr("name","edit_address_select_city");
        var city_id = $.trim($(city).val());
    };
    if(addre==""){
        tishi_alert("地址不能为空!");
    }else if(city_id==undefined || city_id=="0"){
        tishi_alert("请选择一个城市!");
    }else{
        $(obj).parents("form").submit();
    }
}

function edit_address(company_id, add_id){
    $.ajax({
        type: "get",
        url: "/companies/"+company_id+"/address_settings/"+add_id+"/edit",
        dataType: "script"
    })
}

function address_cancel(obj){
    $(".second_bg").hide();
    $(obj).parents(".second_box").hide();
}

$(function(){
    $(".select_tag").on('click',function() {
      $(this).parent(".select_box").find("ul").toggle();
    });
    $(".select_box ul li").on('click', function() {
      $(this).addClass("hover").siblings().removeClass("hover");
      var text = $(this).html();
      var $val = $(this).find("input").val();
      $(this).parents(".select_box").find(".select_tag span").html(text);
      $(this).parents(".select_box").find("input.tag_input").val($val);
      $(this).parents(".select_box").find(".select_tag span input").attr("name","positions[types]")
      $(this).parents(".select_box").find("ul").hide();
    });

    $(document).bind('click', function(e) {
      var $clicked = $(e.target);
      if (! $clicked.parents().hasClass("select_box"))
        $(".select_box ul").hide();

    });

  });
   