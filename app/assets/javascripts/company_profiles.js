

function close_tuwen(obj){
    if(confirm("是否移除？"))
    $(obj).parent().remove();
}
function change_file(obj){
    $(obj).parent().submit();
}
function submit_comany_profiles(){
    var tuwens = $("#tuwen_box").find(".tuwenBox")
    for(var i=0;i<tuwens.length;i++){
        var img = $(tuwens[i]).find(".tuwenImg").find("span").html();
        var text =  $.trim($(tuwens[i]).children("textarea").val());
        if(img =="请点击上传图片" && text==""){
            alert("图片文字至少要写一个");
            return false;
        }
        $(tuwens[i]).css();
    }
    var html = $("#tuwen_box").html();
    $("#html_content").val(html);
}