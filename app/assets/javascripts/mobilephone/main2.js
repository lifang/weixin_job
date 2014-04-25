$(function(){
    var secret_key = getQueryString("secret_key");
    $("#create_client_resume_form").prepend("<input type='hidden' name='secret_id' value='"+secret_key+"'/>");
})


function client_resume_valid(obj){
    var flag = true;
    var msg = ""
    $(".itemBox").find("input[type='text']").each(function(){
        if($.trim($(this).val())==""){
            flag = false;
            var name = $(this).prev("label").text();
            msg += name+"不能为空!\r\n";
        }
    });
    $(".itemBox").find("input[type='file']").each(function(){
        var name = $(this).prev("label").text();
        var input_name = $(this).attr("name");
        if(input_name.indexOf("headimage")>0 && $(this).val()!=""){
                var img = $.trim($(this).val());
                var img_format =["png","gif","jpg","bmp","jpeg","JPG","PNG","BMP","JPEG","GIF"];
                var img_type = img.substring(img.lastIndexOf(".")).toLowerCase();
                if(img_format.indexOf(img_type.substring(1,img_type.length))==-1){
                    flag = false;
                    msg += name + "请上传正确的头像图片,图片格式可以为"+img_format+"\r\n";
                }
        }
    })
    $(".checkItem").each(function(){
        var i = 0;
        $(this).find("input[type='checkbox']:checked").each(function(){
            i += 1;
        });
        if(i==0){
            flag = false;
            var name = $(this).find("label").first().text();
            msg += name+"至少选择一个!\r\n";
        }
    })
    var key = $("input[name='secret_id']").first().val();
    if(key=="" || key=="null"){
        msg +="缺少secret_key";
        flag = false;
    }
    if(flag){
        $(obj).parents("form").submit();
    }else{
        alert(msg);
    }
}

function edit_client_resume_valid(obj){
    var flag = true;
    var msg = ""
    $("#edit_resume_div").find("input[type='text']").each(function(){
        if($.trim($(this).val())==""){
            flag = false;
            var name = $(this).prev("label").text();
            msg += name+"不能为空!\r\n";
        }
    });
    $(".checkItem").each(function(){
        var i = 0;
        $(this).find("input[type='checkbox']:checked").each(function(){
            i += 1;
        });
        if(i==0){
            flag = false;
            var name = $(this).find("label").first().text();
            msg += name+"至少选择一个!\r\n";
        }
    });

    $(".itemBox").find("input[type='file']").each(function(){
        var input_name = $(this).attr("name");
        if($(this).val()!="" && input_name.indexOf("headimage")>0){
            var name = $(this).prev("label").text();
            var img = $.trim($(this).val());
            var img_format =["png","gif","jpg","bmp","jpeg","JPG","PNG","BMP","JPEG","GIF"];
            var img_type = img.substring(img.lastIndexOf(".")).toLowerCase();
            if(img_format.indexOf(img_type.substring(1,img_type.length))==-1){
                flag = false;
                msg += name + "请上传正确的头像图片,图片格式可以为"+img_format+"\r\n";
            }
        }
    });
    if(flag){
        $(obj).parents("form").submit();
    }else{
        alert(msg);
    }
}

function getQueryString(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null) return unescape(r[2]);
    return null;
}