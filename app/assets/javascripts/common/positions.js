function position_edit(obj){
    var types_id = $(obj).find(".types_id").val() ;
    var description = $(obj).find(".description").val() ;
    var name = $(obj).find(".name").val() ;
    ($(".jobInfo").find('input[type=text]').val(name));
    ($(".jobInfo").find('#types').val(types_id));
    window.editor.html(description);
}

function character_limit(obj,num){
    if($(obj).val().length>num){
        $(obj).val($(obj).val().substring(0,num));
        tishi_alert("字数不能超过500");
    }
}

function check_position(){
    if($("#types").val()==0 || $("#types").val()== null ){
        tishi_alert('请选择职位类型！');
        return false;
    }
    var name = $.trim( $(".jobInfo").find('input[type=text]').val())
    if(name == ""){
        tishi_alert("名称不能为空！");
        return false;
    }
    if(name.length > 15){
        tishi_alert("名称不能超过15个字！");
        return false;
    }
    var description =window.editor.text();
    if(description == ""){
        tishi_alert("描述不能为空！");
        return false;
    }
    if(description.length>500){
        tishi_alert("描述不能大于500字！");
        return false;
    }
    $(".jobInfo").children("form").submit();
}

function search_position(obj,url){
    var position = $(obj).parent().children("input").val();
    location.href=url+"/search_position?position=" + $.trim(position);

}

function submit_position_types(obj){
    
    if($.trim($("#name").val())==""){
        tishi_alert('名称不能为空！');
        return false;
    }
    if($.trim($("#name").val()).length > 8){
        tishi_alert('名称不能超过8个字！');
        return false;
    }

    $(obj).parent().parent().submit();
}

function cancel_position_types(obj){
    $(".second_bg").hide();
    $(".newJobCategory").hide();
}