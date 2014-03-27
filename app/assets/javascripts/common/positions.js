function position_edit(obj){
    var types_id = $(obj).find(".types_id").val() ;
    var description = $(obj).find(".description").val() ;
    var requirement = $(obj).find(".requirement").val() ;
    var name = $(obj).find(".name").val() ;
    ($(".jobInfo").find('input[type=text]').val(name));
    ($(".jobInfo").find('#types').val(types_id));
    var editor = KindEditor.instances;
    editor[0].html(description);
    editor[1].html(requirement);
    var addrs = $(obj).find(".address_id");
    var addr_names = $(obj).find(".address_name");
    var arr=[],add_arr =[]
    for(var i=0 ;i<addrs.length;i++){
            arr.push($(addrs[i]).val());
            add_arr.push($(addr_names[i]).val());
    }
    var str=""
    for(var i=0 ;i<add_arr.length;i++){
        str += add_arr[i]+"</br>"
        str += "<input type='hidden' name='address_id[]' value='"+arr[i]+"' />"
    }
    if(str==""){
        str="请点击选择工作地点"
    }
    var span = $(".jobInfo").find(".place").find("span");
    span.html(str);
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
    var place = $.trim($(".jobInfo").find(".place span").text());
    if(place == "请点击选择工作地点"){
        tishi_alert("请点击选择工作地点！");
        return false;
    }
    var editor = KindEditor.instances;
    var description =editor[0].text();
    if(description == ""){
        tishi_alert("描述不能为空！");
        return false;
    }
    if(description.length>500){
        tishi_alert("描述不能大于500字！");
        return false;
    }
    var req =editor[1].text();
    if(req == ""){
        tishi_alert("任职要求不能为空！");
        return false;
    }
    if(req.length>500){
        tishi_alert("任职要求不能大于500字！");
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

function add_work_address(obj,company_id){
    var checks = $(".largeCon").find(".check");
    var arr=[],add_arr =[]
    for(var i=0 ;i<checks.length;i++){
        if($(checks[i]).attr("class")=="check checked"){
            arr.push($(checks[i]).find("input").val());
            add_arr.push($($(checks[i]).parent().find("span")[0]).html());
        }
    }
    str =""
    for(var i=0 ;i<add_arr.length;i++){
        str += add_arr[i]+"</br>"
        str += "<input type='hidden' name='address_id[]' value='"+arr[i]+"' />"
    }
    var span = $(".jobInfo").find(".place").find("span");
    span.html(str);
    add_menu_cancel(obj)
}