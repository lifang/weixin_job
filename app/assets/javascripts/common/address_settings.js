function new_addre_button(){
    $(".second_bg").show();
    $("#new_addre_div").show();
}

function address_search_city(obj,company_id,type){
    var province_id = $(obj).find("option:selected").val();
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
                    $("#new_address_select_city").append("<option value='0'>----</option>")
                    $.each(data.cities, function(key,value){
                        $("#new_address_select_city").append("<option value='"+value.id+"'>"+value.name+"</option>");
                    })
                }else{
                    $("#edit_address_select_city").empty();
                    $("#edit_address_select_city").append("<option value='0'>----</option>")
                    $.each(data.cities, function(key,value){
                        $("#edit_address_select_city").append("<option value='"+value.id+"'>"+value.name+"</option>");
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
        },
        error: function(data){
            tishi_alert("数据错误!");
        }
    })
}

function address_valid(obj,type){    
    if(type==0){
        var addre = $.trim($(obj).parents("form").find("input[name='new_addre']").first().val());
        var city_id = $.trim($("#new_address_select_city").find("option:selected").val());
    }else{
        var addre = $.trim($(obj).parents("form").find("input[name='edit_addre']").first().val());
        var city_id = $.trim($("#edit_address_select_city").find("option:selected").val());
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

