function add_menu(level, parent_id, menu_length){
    if(level==1){
        if(menu_length >= 3){
            tishi_alert("每个一级菜单最多只能保持3个!");
        }else{
            $("#add_menu_div").find("h1[name='add_menu_h1']").first().text("新建一级菜单");
            $("#add_menu_div").find("input[name='parent_id']").remove();
            $("#add_menu_div").find("h1[name='add_menu_h1']").first().after("<input type='hidden' name='parent_id' value='"+parent_id+"' />");
            $(".second_bg").show();
            $("#add_menu_div").show();
        }
    }else{
        if(menu_length >= 5){
            tishi_alert("每个一级菜单的二级菜单最多只能保持5个!");
        }else{
            $("#add_menu_div").find("h1[name='add_menu_h1']").first().text("新建二级菜单");
            $("#add_menu_div").find("input[name='parent_id']").remove();
            $("#add_menu_div").find("h1[name='add_menu_h1']").first().after("<input type='hidden' name='parent_id' value='"+parent_id+"' />");
            $(".second_bg").show();
            $("#add_menu_div").show();
        }
    }
}
function add_menu_new(level, parent_id, menu_length){
    if(level==1){
        if(menu_length >= 3){
            tishi_alert("每个一级菜单最多只能保持3个!");
        }else{
            $(".add_menu_new").find("input[name='parent_id']").first().val(parent_id);
            tab_function($(".add_menu_new"));
        }
    }else{
        if(menu_length >= 5){
            tishi_alert("每个二级菜单最多只能保持5个!");
        }else{
            $(".add_menu_new").find("input[name='parent_id']").first().val(parent_id);
            tab_function($(".add_menu_new"));
        }
    }
}

function menu_new_commit(company_id){
    var top = $(".add_menu_new").find(".linkPicker");
    var table_1_h = $(top).find(".tabDiv_1");
    var table = $(top).find(".tabDiv_1.hover");
    var parent_id = $(".add_menu_new").find("input[name='parent_id']").first().val();
    var menu_name = $(".add_menu_new").find("#menu_name").val();
    var menu_type = 0,temp_id =0,file_path = undefined;
    if($.trim(menu_name)=="" ){
        tishi_alert("请输入菜单名称!");
        return false;
    }
    var index =-1;
    index = $(table_1_h).index(table);
    if(index==0){
        menu_type = 0;
        temp_id = $(table).find("input[type=radio]:checked").val();
    }else if(index == 1){
        menu_type = 2;
        temp_id = $(table).find("input[type=radio]:checked").val();
    }else if(index == 2){
        menu_type = 3;
        file_path = $(table).find("#out_link").val();
        if($.trim(file_path)=="" ){
            tishi_alert("请输入链接!");
            return false;
        }
    }
    $.ajax({
        type: "post",
        url: "/companies/"+company_id+"/menus",
        dataType: "script",
        data: {
            parent_id : parent_id,
            menu_name : menu_name,
            menu_type : menu_type,
            temp_id : temp_id,
            file_path : file_path
        },
        success:function(data){
        }
    })
}

function menu_edit_commit(company_id,menu_id){
    var top = $(".add_menu_edit").find(".linkPicker");
    var table_1_h = $(top).find(".tabDiv_1");
    var table = $(top).find(".tabDiv_1.hover");
    var parent_id = $(".add_menu_edit").find("input[name='parent_id']").first().val();
    var menu_name = $(".add_menu_edit").find("#menu_name").val();
    var menu_type = 0,temp_id =0,file_path = undefined;
    if($.trim(menu_name)=="" ){
        tishi_alert("请输入菜单名称!");
        return false;
    }
    var index =-1;
    index = $(table_1_h).index(table);
    if(index==0){
        menu_type = 0;
        temp_id = $(table).find("input[type=radio]:checked").val();
    }else if(index == 1){
        menu_type = 2;
        temp_id = $(table).find("input[type=radio]:checked").val();
    }else if(index == 2){
        menu_type = 3;
        file_path = $(table).find("#out_link").val();
        if($.trim(file_path)=="" ){
            tishi_alert("请输入链接!");
            return false;
        }
    }
    alert(temp_id);
    $.ajax({
        type: "put",
        url: "/companies/"+company_id+"/menus/"+menu_id,
        dataType: "script",
        data: {
            parent_id : parent_id,
            menu_name : menu_name,
            menu_type : menu_type,
            temp_id : temp_id,
            file_path : file_path
        }
    })
}

function add_selected(obj){
    if($(obj).attr("class")=="check checked"){
        $(obj).attr("class", "check");
    }else{
        $(".second_content").find("span[class='check checked']").each(function(){
            $(this).attr("class", "check");
        });
        $(obj).attr("class", "check checked");
    }
}
function add_selected1(obj){
    if($(obj).attr("class")=="check checked"){
        $(obj).attr("class", "check");
    }else{
        $(obj).attr("class", "check checked");
    }

}
function add_menu_commit(company_id){
    var parent_id = $("#add_menu_div").find("input[name='parent_id']").first().val();
    var menu_name = $("#add_menu_div").find("input[name='menu_name']").first().val();
    if($.trim(menu_name)=="" ){
        tishi_alert("请输入菜单名称!");
    }else{
        var menu_type = $("#add_menu_div").find("span[class='check checked']").first().find("input[name='menu_type']").val();
        var temp_id = $("#add_menu_div").find("span[class='check checked']").first().find("input[name='temp_id']").val();
        var file_path = $("#add_menu_div").find("span[class='check checked']").first().find("input[name='file_path']").val();
        var file_path2 = file_path==undefined ? "" : file_path;
        $.ajax({
            type: "post",
            url: "/companies/"+company_id+"/menus",
            dataType: "script",
            data: {
                parent_id : parent_id,
                menu_name : menu_name,
                menu_type : menu_type,
                temp_id : temp_id,
                file_path : file_path2
            }
        })
    }
}

function add_menu_cancel(obj){
    $(".second_bg").hide();
    $(obj).parents(".second_box").hide();
}
function show_edit_area(company_id,id){
    $.ajax({
        url:"/companies/"+company_id+"/menus/"+id+"/show_edit_menu",
        dataType:"script"
    });
}
function edit_menu(level, parent_id, temp_id, menu_name, menu_type, menu_id){
    if(level==1){
        $("#edit_menu_div").find("h1[name='edit_menu_h1']").first().text("编辑一级菜单");
    }else{
        $("#edit_menu_div").find("h1[name='edit_menu_h1']").first().text("编辑二级菜单");
    };
    $("#edit_menu_div").find("input[name='edit_parent_id']").remove();
    $("#edit_menu_div").find("h1[name='edit_menu_h1']").first().after("<input type='hidden' name='edit_parent_id' value='"+parent_id+"' />");
    $("#edit_menu_div").find("h1[name='edit_menu_h1']").first().after("<input type='hidden' name='edit_menu_id' value='"+menu_id+"' />");
    $("#edit_menu_div").find("input[name='edit_menu_name']").val(menu_name);
    $("#edit_menu_div").find(".check").each(function(){
        $(this).attr("class", "check");
        var span_menu_type = $(this).find("input[name='menu_type']").first().val();
        var span_temp_id = $(this).find("input[name='temp_id']").first().val();
        if(span_temp_id==temp_id && span_menu_type==menu_type){
            $(this).attr("class", "check checked");
        }

    })
    $(".second_bg").show();
    $("#edit_menu_div").show();
}

function edit_menu_commit(company_id){
    var parent_id = $("#edit_menu_div").find("input[name='edit_parent_id']").first().val();
    var menu_name = $("#edit_menu_div").find("input[name='edit_menu_name']").first().val();
    var menu_id = $("#edit_menu_div").find("input[name='edit_menu_id']").first().val();
    if($.trim(menu_name)=="" ){
        tishi_alert("请输入菜单名称!");
    }else{
        var menu_type = $("#edit_menu_div").find("span[class='check checked']").first().find("input[name='menu_type']").val();
        var temp_id = $("#edit_menu_div").find("span[class='check checked']").first().find("input[name='temp_id']").val();
        var file_path = $("#edit_menu_div").find("span[class='check checked']").first().find("input[name='file_path']").val();
        var file_path2 = file_path==undefined ? "" : file_path;
        $.ajax({
            type: "put",
            url: "/companies/"+company_id+"/menus/"+menu_id,
            dataType: "script",
            data: {
                parent_id : parent_id,
                menu_name : menu_name,
                menu_type : menu_type,
                temp_id : temp_id,
                file_path : file_path2
            }
        })
    }
}