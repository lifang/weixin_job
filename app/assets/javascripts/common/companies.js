function edit_has_app(obj, app_type){
    if($(obj).val()==1){    //有app
        $("#company_app_account").removeAttr("disabled");
        $("#company_app_password").removeAttr("disabled");
        if(app_type==0){
            $("#edit_app_notice_p").remove();
            $("#edit_app_div").prepend("<p id='edit_app_notice_p'><label>您当前的微信公众账号为订阅号,请在下面输入正确的微信公众平台登陆账号和密码!</label></p>");
        }
    }else{  //无app
        $("#edit_app_notice_p").remove();
        $("#company_app_account").attr("disabled", "disabled");
        $("#company_app_password").attr("disabled", "disabled");
    }
}

function edit_company_valid(obj, type){
    if(type==0){
        if($.trim($("#company_name").val())==""){
            alert("公司名称不能为空!");
        }else if($.trim($("#company_cweb").val())==""){
            alert("公众号token不能为空!")
        }else if($.trim($("#company_app_id").val())==""){
            alert("AppId不能为空!")
        }else if($.trim($("#company_app_secret").val())==""){
            alert("AppSecret不能为空!")
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