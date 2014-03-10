function edit_company_valid(obj, type){
    if(type==0){
        if($.trim($("#company_name").val())==""){
            alert("公司名称不能为空!");
        }else if($.trim($("#company_cweb").val())==""){
            alert("公众号不能为空!")
        }else if($.trim($("#company_token").val())==""){
            alert("token不能为空!")
        }else{
            $(obj).parents("form").submit();
        }
    }else if(type==1){
        var has_app = ($(obj).parents("form").find("input[name='has_app']:checked").val());
        var flag = true;
        if(has_app==1){
            if($.trim($("#company_app_account").val())==""){
                alert("app账号不能为空!");
                flag = false;
            }else if($.trim($("#company_app_password").val())==""){
                alert("app密码不能为空!");
                flag = false;
            }
        }
        if(flag){
            $(obj).parents("form").submit();
        }
    }
}

function edit_company_cancel(obj){
    $(obj).parents(".second_box").hide();
    $(".second_bg").hide();
}