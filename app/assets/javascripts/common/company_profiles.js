

function close_tuwen(obj){
    if(confirm("是否移除？")){
        var length =$("#tuwen_box").children().length;
        if(length == 1){
            tishi_alert("至少保证一块图文！");
        }else{
            $(obj).parent().remove();
        }
    }
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
        tishi_alert("标题不能为空");
        return false;
    }
    var file_name = $.trim($("#file_name").val());
    if(file_name==""){
        tishi_alert("文件名不能为空");
        return false;
    }
    var tuwens = $("#tuwen_box").find(".tuwenBox");
    for(var i=0;i<tuwens.length;i++){
        var img =  $(tuwens[i]).find(".tuwenImg").find(".company_image").val();
        var text =  $.trim($(tuwens[i]).children("textarea").val());
        if(img == "#" && text==""){
            5
            tishi_alert("图片文字至少要写一个");
            return false;
        }
        $(tuwens[i]).children("textarea").html( text );
        $(".img_area").append("<input type='hidden' name='image[]' value='"+img+"'/>");
        $(".text_area").append("<input type='hidden' name='text[]' value='"+text+"'/>");
    }
    $("#send_title").val(title);
    $("#send_file_name").val(file_name);
    var html = $("#tuwen_box").html();
    $("#html_content").val(html);
    $("#company_profiles_id").submit();
}

function show_tuwen_box(obj,company_id){
    var job_temp = $(".jobTemp");
    for(var j=0;j<job_temp.length;j++){
        $(job_temp[j]).removeClass("checked");
    }
    $(obj).addClass("checked");
    var id = $(obj).children("#id").val();

    $.ajax({
        async : true,
        type : 'get',
        url:"/companies/"+ company_id +"/company_profiles/"+id +"/show_tuwen_page",
        dateType:"script"
    });
    
}