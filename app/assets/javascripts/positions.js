function position_edit(obj){
     var id = $(obj).find(".id").val() ;
     var description = $(obj).find(".description").val() ;
     var name = $(obj).find(".name").val() ;
     ($(".jobInfo").find('.id').val(id));
     ($(".jobInfo").find('input[type=text]').val(name));
     ($(".jobInfo").find('textarea').val(description));
}
function check_position(){
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