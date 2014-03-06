function position_edit(obj){
     var id = $(obj).find(".id").val() ;
     var description = $(obj).find(".description").val() ;
     var name = $(obj).find(".name").val() ;
     ($(".jobInfo").find('.id').val(id));
     ($(".jobInfo").find('input[type=text]').val(name));
     ($(".jobInfo").find('textarea').val(description));
}