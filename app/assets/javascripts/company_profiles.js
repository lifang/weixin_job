

function close_tuwen(obj){
    if(confirm("是否移除？"))
    $(obj).parent().remove();
}
function change_file(obj){
    var index=-1;
    var this_tuwen = $(obj).parents(".tuwenBox")[0];
    var tuwens = $("#tuwen_box").find(".tuwenBox");
    for(var i=0;i<tuwens.length;i++){
        if(this_tuwen == tuwens[i]){
            index = i;
        }
    }
    var old_img_url = $(tuwens[index]).find(".tuwenImg").css("background-image");
    $(obj).parent().find("#index").val(index);
    $(obj).parent().find("#old_img").val(old_img_url);
    $(obj).parent().submit();
}
function submit_comany_profiles(){
    $(".img_area").html("");
    $(".text_area").html("");
    var title = $.trim($("#title").val());
    if(title==""){
            alert("标题不能为空");
            return false;
    }
    var file_name = $.trim($("#file_name").val());
    if(file_name==""){
            alert("文件名不能为空");
            return false;
    }
    var tuwens = $("#tuwen_box").find(".tuwenBox");
    for(var i=0;i<tuwens.length;i++){
        var img =  $(tuwens[i]).find(".tuwenImg").find(".company_image").val();
        var text =  $.trim($(tuwens[i]).children("textarea").val());
        if(img == "#" && text==""){5
            alert("图片文字至少要写一个");
            return false;
        }
        $(".img_area").append("<input type='hidden' name='image[]' value="+img+">");
        $(".text_area").append("<input type='hidden' name='text[]' value="+text+">");
    }
    $("#send_title").val(title);
    $("#send_file_name").val(file_name);
    var html = $("#tuwen_box").html();
    $("#html_content").val(html);
    $("#company_profiles_id").submit();
}