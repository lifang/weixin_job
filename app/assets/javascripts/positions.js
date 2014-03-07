function position_edit(obj){
     var id = $(obj).find(".id").val() ;
     var types_id = $(obj).find(".types_id").val() ;
     var description = $(obj).find(".description").val() ;
     var name = $(obj).find(".name").val() ;
     ($(".jobInfo").find('.id').val(id));
     ($(".jobInfo").find('input[type=text]').val(name));
     ($(".jobInfo").find('textarea').val(description));
     ($(".jobInfo").find('#types').val(types_id));
}
function check_position(){
    if($("#types").val()==0 || $("#types").val()== null ){
        alert('请选择职位类型！');
        return false;
    }
   var name = $.trim( $(".jobInfo").find('input[type=text]').val())
   if(name == ""){
       alert("名称不能为空！");
       return false;
   }
   var description = $.trim( $(".jobInfo").find('textarea').val())
   if(description == ""){
       alert("描述不能为空！");
       return false;
   }
   $(".jobInfo").children("form").submit();
}

function search_position(obj,url){
    var position = $(obj).parent().children("input").val();
    location.href=url+"/search_position?position=" + position;

}

function submit_position_types(obj){
    
    if($.trim($("#name").val())==""){
        alert('名称不能为空！');
        return false;
    }
    $(obj).parent().parent().submit();
}

function cancel_position_types(obj){
    $(".second_bg").hide();
    $(".newJobCategory").hide();
}