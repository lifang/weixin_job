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
function change_status(obj,company_id,p_and_r_id,status){
    if(confirm("确认拒绝？")){
        $.ajax({
            url:"/companies/"+company_id+"/resumes/"+p_and_r_id+"/change_status",
            data:"status="+status,
            dataType:'text',
            success :function(d){
                if(d==1){
                    tab_function($('.refuse'));
                    location.reload();
                }else{
                    tishi_alert("操作失败！");
                }

            }
        });
    }
}
function tab_function(t){
    var win_width = $(window).width();
    var win_height = $(window).height();
    var doc_width = $(document).width();
    var doc_height = $(document).height();
    var layer_height = $(t).height();
    var layer_width = $(t).width();
    $(t).css('display','block');
    $(this).parent().css("display","none");
    //$(this).parents(".tab").css('display','block');
    $(t).css('top',(doc_height-$(window).scrollTop()-layer_height)/2);
    $(t).css('left',(win_width-layer_width)/2);
    $(".close, .cancel").click(function(){
        //$(this).parent().css("display","none");
        //$(this).parents(".tab").css("display","none");
        $(t).css('display','none');
    });
}
        

function deal_audition(obj,company_id,p_and_r_id){
    $("#audition_form").attr("action","/companies/"+company_id+"/resumes/"+p_and_r_id+"/deal_audition");
    tab_function( $(".audition"));
}
function deal_join(company_id,p_and_r_id){
    $("#join_form").attr("action","/companies/"+company_id+"/resumes/"+p_and_r_id+"/deal_join");
    tab_function( $(".join"));
}
function submit_audition_form(obj){
    var form = $(obj).parents("#audition_form");
    var input =$(form).find("input");
    var textarea =$.trim($(form).find("textarea").val());
    if($.trim($(input[0]).val())== "" ){
        tishi_alert("时间不能为空！");
        return false;
    }
    if($.trim($(input[1]).val())== "" ){
        tishi_alert("地址不能为空！");
        return false;
    }
    if(textarea.length > 250 ){
        tishi_alert("备注长度不能大于250！");
        return false;
    }
    form.submit();   
}


function submit_join_form(obj){
    var form = $(obj).parents("#join_form");
    var input =$(form).find("input");
    var textarea =$.trim($(form).find("textarea").val());
    if($.trim($(input[0]).val())== "" ){
        tishi_alert("时间不能为空！");
        return false;
    }
    if($.trim($(input[1]).val())== "" ){
        tishi_alert("地址不能为空！");
        return false;
    }
    if(textarea.length > 250 ){
        tishi_alert("备注长度不能大于250！");
        return false;
    }
    form.submit();
}
function search_positon_resumes(obj){
    var form = $(obj).parent().parent();
    $(".select_tag").find("input").attr("name","position_id");
    var postion_id = $(form).find("input[name='position_id']").val();
    var start = $(form).find("input[name='start']").val();
    var end = $(form).find("input[name='end']").val();
    if(end==""&&postion_id==0&&start==""){
        tishi_alert("请至少选择一个条件！");
        return false;
    }
    form.submit();
}
function show_the_position(obj){
    var content = $(obj).find("option:selected").text();
    $(obj).parent().find(".search_position").html(content);
}
function show_resume(company_id,client_resume_id){
    location.href = "/companies/"+company_id+"/resumes/show_resume?client_resume_id="+client_resume_id;
}

function cancle_the_box(obj){
    $(".second_bg").hide();
    $(".second_box_fixed").hide();
}