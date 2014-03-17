$(function(){
    $("#form_div").sortable();
    //$("#form_div .itemBox").draggable();
})

function remove_form_item(obj, name){     //删除简历模板中的某个元素
    $(obj).parent("div .itemBox").remove();
}

function del_tag_p(obj){
    var len = $(obj).parents(".insetBox").find(".optBox").length;
    if(len <=1){
        tishi_alert("至少保留一个选项!");
    }else{
        $(obj).parents("p").remove();
    }
}

function add_tag_p(name,obj){
    if(name=="radio_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>单选框选项：</label><input type='text' name='add_radion_option'/><span class='close_1' onclick='del_tag_p(this)' style='cursor:pointer;'>×</span></p>");
    }else if(name=="checkbox_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>复选框选项：</label><input type='text' name='add_checkbox_option'/><span class='close_1' onclick='del_tag_p(this)' style='cursor:pointer;'>×</span></p>");
    }else if(name=="select_div"){
        $(obj).parents(".second_content").find(".insetBox").append("<p class='optBox'><label>下拉框选项：</label><input type='text' name='add_select_option'/><span class='close_1' onclick='del_tag_p(this)' style='cursor:pointer;'>×</span></p>");
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
    }else if(name=="head_image_div"){
        title_name = "headimage";
    }else if(name=="file_div"){
        title_name = "file_"+index;
    }else if(name=="text_div"){
        title_name = "text_"+index;
    }else if(name=="radio_div"){
        title_name = "radio_"+index;
    }else if(name=="check_box_div"){
        title_name = "checkbox_"+index;
    }else if(name=="select_div"){
        title_name = "select_"+index;
    }else if(name == "add_tag_div"){
        title_name = "tag_"+index;
    }
    var item_title = $(obj).parents(".second_content").find("input[name='add_item_title']").first().val();  //:name => 'xxx''

    if (name!="success_div" && $.trim(item_title)==""){
        tishi_alert("标题不能为空!");

    }else{
        if(name=="message_div" || name=="head_image_div" || name=="file_div" || name=="text_div"){   //图片、填空、文本只需传标题值
            if(name=="head_image_div"){
                var len = $(".head_image_div").length;
                if(len>=1){
                    tishi_alert("头像最多只有一个!");
                }else{
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
                }
            }else{
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
            }

        }else if(name=="radio_div"){
            var radio_ops = new Array;
            var flag = true;
            $(obj).parents(".second_content").find("input[name='add_radion_option']").each(function(){
                var vle = $.trim($(this).val());
                if(vle==""){                   
                    flag = false;
                }else{
                    radio_ops.push($(this).val());
                }
            });
            if(flag){
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
            }else{
                tishi_alert("选项名称不能为空!");
            }
        }else if(name=="check_box_div" || name=="add_tag_div"){
            var checkbox_ops = new Array;
            var flag = true;
            $(obj).parents(".second_content").find("input[name='add_checkbox_option']").each(function(){
                var vle = $.trim($(this).val());
                if(vle==""){
                    flag = false;
                }else{
                    checkbox_ops.push(vle);
                }
            });
            if(flag){
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
            }else{
                tishi_alert("选项名称不能为空!");
            }
        }else if(name=="select_div"){
            var select_ops = new Array;
            flag = true;
            $(obj).parents(".second_content").find("input[name='add_select_option']").each(function(){
                var vle = $.trim($(this).val());
                if(vle==""){
                    flag = false;
                }else{
                    select_ops.push(vle);
                }
            });
            if(flag){
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
            }else{
                tishi_alert("选项名称不能为空!");
            }
        }
    }
}

function sortNumber(a,b){
    return b - a
}

function create_resume_valid(obj){
    var headimg_len = $(".phoneVirtual").find(".head_image_div").length;
    if(headimg_len > 1){
        tishi_alert("最多有一个上传头像!");
    }else{
        $(obj).parents("form").submit();
    }
}


