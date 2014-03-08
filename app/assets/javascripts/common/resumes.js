function remove_form_item(obj){     //删除简历模板中的某个元素
    var class_name = $(obj).parent("div .itemBox").attr("class");
    if(class_name.indexOf("success_div")>=0){
        var len = $(obj).parents("div .phoneVirtual").find(".success_div").length;
        if(len<=1){
            alert("至少保留一个注册成功后跳转的页面!")
        }else{
            $(obj).parent("div .itemBox").remove();
        }
    }else{
        $(obj).parent("div .itemBox").remove();
    }
}

function del_tag_p(obj){
    $(obj).parents("p").remove();
}

function add_tag_p(name,obj){
    if(name=="radio_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>单选框选项：</label><input type='text' name='add_radion_option'/><span class='close_1' onclick='del_tag_p(this)'>×</span></p>");
    }else if(name=="checkbox_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>复选框选项：</label><input type='text' name='add_checkbox_option'/><span class='close_1' onclick='del_tag_p(this)'>×</span></p>");
    }else if(name=="select_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>下拉框选项：</label><input type='text' name='add_select_option'/><span class='close_1' onclick='del_tag_p(this)'>×</span></p>");
    }

}
function add_form_item(name,obj,company_id){
    var arr = new Array;
    $("."+name).find("input[name='k_name']").each(function(){
        arr.push($(this).val().split("_")[1]);
    });
    var a = arr.sort(sortNumber)[0];
    var index;
    if(a==undefined || a==""){
        index = 1;
    }else{
        index = parseInt(a) + 1;
    }
    var title_name;     //xxx_2
    if(name=="message_div"){
        title_name = "message_"+index;
    }else if(name=="image_div"){
        title_name = "image_"+index;
    }else if(name=="text_div"){
        title_name = "text_"+index;
    }else if(name=="radio_div"){
        title_name = "radio_"+index;
    }else if(name=="check_box_div"){
        title_name = "checkbox_"+index;
    }else if(name=="select_div"){
        title_name = "select_"+index;
    }else if(name=="success_div"){
        title_name = "success_"+index;
    }
    var item_title = $(obj).parents(".second_content").find("input[name='add_item_title']").first().val();  //:name => 'xxx''
    if(name=="message_div" || name=="image_div" || name=="text_div"){
        $.ajax({
            type: "get",
            url: "/companies/"+company_id+"/resumes/add_form_item",
            dataType: "script",
            data: {
                name : name,
                title_name : title_name,
                item_title : item_title
            }
        })
    }else if(name=="success_div"){
        var al = $(obj).parents(".second_content").find("input[name='add_item_alert']").first().val();
        var phone = $(obj).parents(".second_content").find("input[name='add_item_phone']").first().val();
        var address = $(obj).parents(".second_content").find("input[name='add_item_address']").first().val();
        $.ajax({
            type: "get",
            url: "/companies/"+company_id+"/resumes/add_form_item",
            dataType: "script",
            data: {
                name : name,
                title_name : title_name,
                al : al,
                phone : phone,
                address : address
            }
        })
    }else if(name=="radio_div"){
        var radio_ops = new Array;
        $(obj).parents(".second_content").find("input[name='add_radion_option']").each(function(){
            radio_ops.push($(this).val());
        });
        $.ajax({
            type: "get",
            url: "/companies/"+company_id+"/resumes/add_form_item",
            dataType: "script",
            data: {
                name : name,
                title_name : title_name,
                item_title : item_title,
                options : radio_ops
            }
        })
    }else if(name=="check_box_div"){
        var checkbox_ops = new Array;
        $(obj).parents(".second_content").find("input[name='add_checkbox_option']").each(function(){
            checkbox_ops.push($(this).val());
        });
        $.ajax({
            type: "get",
            url: "/companies/"+company_id+"/resumes/add_form_item",
            dataType: "script",
            data: {
                name : name,
                title_name : title_name,
                item_title : item_title,
                options : checkbox_ops
            }
        })
    }else if(name=="select_div"){
        var select_ops = new Array;
        $(obj).parents(".second_content").find("input[name='add_select_option']").each(function(){
            select_ops.push($(this).val());
        });
        $.ajax({
            type: "get",
            url: "/companies/"+company_id+"/resumes/add_form_item",
            dataType: "script",
            data: {
                name : name,
                title_name : title_name,
                item_title : item_title,
                options : select_ops
            }
        })
    }
}

function sortNumber(a,b){
    return b - a
}
