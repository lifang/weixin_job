/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
$(function(){
    $(".temp_explain").on("click", ".green_btn", function(){
        var selector_id = $(this).attr("data-id");
        tab_function($("#" + selector_id));
    })

   $(".tab_btn").on("click", ".chooseReplyType", function(){
       var selector_id = $(this).parents(".tab").attr("id");
       setChoose(selector_id);
   })
   $(".info_bar").on("click", ".x", function(){
       if(confirm("确定移除？")){
           $(this).next().html("");
           $(this).hide();
       }
   })
    
})

function SelectOne(obj){
    $("#add_imgtext").find("p.hRadio").removeClass("hRadio_Checked");
    $(obj).addClass("hRadio_Checked");
}

//关键字回复/自动回复  弹出框选定文字 or 图文
function setChoose(selector_id){
    var set_area = $(".info_bar .seted_area");
    var html;
    if(selector_id == "add_imgtext"){  //图文
        var selectBlock = $("#" + selector_id).find("p.hRadio_Checked");
        var micro_message_id = selectBlock.prev().val();
        html= selectBlock.next().html();
        set_area.html(html);
        $(".micro_message_id").val(micro_message_id);
        $(".micro_message_content").val("");
        $(".solid_link_flag").val("");
    }else if(selector_id == "add_text"){ //文字
        var text = $("#" + selector_id).find(".select_pure_text").val();
        html = HTMLEnCode(text);
        set_area.html("<p>" + html + "</p>");
        $(".micro_message_content").val(html);
        $(".micro_message_id").val("");
        $(".solid_link_flag").val("");
    }else if(selector_id == "add_app_link"){
        var selectlink = $("#" + selector_id).find("p.hRadio_Checked");
        var app_link = selectlink.prev().val();
        html = HTMLEnCode(app_link);
        set_area.html("<p>" + html + "</p>");
        $(".micro_message_content").val(html);
        $(".solid_link_flag").val("app");
        $(".micro_message_id").val("");
    }
    
    set_area.prev().show();
    $("#" + selector_id).hide();
}

//转义字符串
function HTMLEnCode(str)
{
    var    s    =    "";
    if    (str.length    ==    0)    return    "";
    s    =    str.replace(/&/g,    "&gt;");
    s    =    s.replace(/</g,        "&lt;");
    s    =    s.replace(/>/g,        "&gt;");
    s    =    s.replace(/    /g,        "&nbsp;");
    s    =    s.replace(/\'/g,      "&#39;");
    s    =    s.replace(/\"/g,      "&quot;");
    s    =    s.replace(/\n/g,      "<br>");
    return    s;
}

//消息内容不能为空
function checkContent(obj){
     var micro_message_id = $(".micro_message_id").val();
     var content= $(".micro_message_content").val();
     if(micro_message_id == "" && content == ""){
         tishi_alert("内容不能为空！");
         return false;
     }
}

function showFileName(obj){
    var file_name = $(obj).val();
    var show_input = $(obj).parent().find(".fileText_1");
    show_input.val(file_name);
}

//图文消息验证必填
function checkValid(obj){
    flag = true;
    $(obj).parents("form").find("input, textarea").each(function(){
        var title = $(this).attr("data_alt");
        if($.trim($(this).val()) == ""){
            tishi_alert(title + "不能为空！");
            flag = false;
            return flag;
        }
        return flag;
    });
    if(flag){
       $(obj).parents("form").submit();
    }
    
}