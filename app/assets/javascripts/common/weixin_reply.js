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
           $(this).next().remove();
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
        html= selectBlock.next().html();
    }else if(selector_id == "add_text"){ //文字
        var text = $("#" + selector_id).find(".select_pure_text").val();
        html = HTMLEnCode(text);
    }else if(selector_id == "add_app_link"){
        var selectlink = $("#" + selector_id).find("p.hRadio_Checked");
        var app_link = selectlink.prev().val();
        html = HTMLEnCode(app_link);
    }
    set_area.html(html);
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