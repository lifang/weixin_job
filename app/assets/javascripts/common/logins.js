function login_valid(obj){
    if($.trim($("#comp_account").val())==""){
       tishi_alert("请输入用户名!");
    }else if($.trim($("#comp_password").val())==""){
       tishi_alert("请输入密码!");
    }else{
        $(obj).parents("form").submit();
    }
}

function regist_valid(obj){
    if($.trim($("#regist_comp_name").val())==""){
       tishi_alert("公司名称不能为空!");
    }else if($.trim($("#regist_comp_account").val())==""){
       tishi_alert("用户名不能为空!");
    }else if($.trim($("#regist_comp_password").val())==""){
       tishi_alert("密码不能为空!");
    }else{
       $(obj).parents("form").submit();
    }
}

function regist_valid_cancel(){
    window.location.href="/"
}