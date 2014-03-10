/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


Date.prototype.format = function(format) {
    var o = {
        "M+" : this.getMonth() + 1, //month
        "d+" : this.getDate(), //day
        "h+" : this.getHours(), //hour
        "m+" : this.getMinutes(), //minute
        "s+" : this.getSeconds(), //second
        "q+" : Math.floor((this.getMonth() + 3) / 3), //quarter
        "S" : this.getMilliseconds() //millisecond
    }
    if (/(y+)/.test(format))
        format = format.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    for (var k in o)
        if (new RegExp("(" + k + ")").test(format))
            format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length));
    return format;
}


$(function(){
    $("body").on("click", ".warnArea .time", function() {
        var txtArea = $(this).parents(".warnArea").find(".warnTxt textarea");
        txtArea.val(txtArea.val() + "[[时间]]");
    })
    $("body").on("click", ".warnArea .space", function() {
        var txtArea = $(this).parents(".warnArea").find(".warnTxt textarea");
        txtArea.val(txtArea.val() + "[[填空]]");
    })

    $("body").on("click", "input.time_or_day", function(){
        $(this).next().removeAttr("disabled").focus();
        var parent = $(this).parent();
        if(parent.hasClass("first")){
            parent.next().find("input[type=text]").val("").attr("disabled", true)
        }else{
            parent.prev().find("input[type=text]").val("").attr("disabled", true);
        }
    })
})

//保存app登记页面html
function saveHtml(obj){
    $("#html_content").val($(".phoneVirtual").html());
    $(obj).parents("form").submit();
}

function check_remind_nonempty(obj) {
    var todays = new Date().format('yyyy-MM-dd')
    var form = $(obj).parents("form");
    if ($.trim(form.find("#remind_title").val()) == "") {
        alert('提示:\n\n名称不能为空');
        return false;
    } else if ($.trim(form.find("#remind_reseve_time").val()) == "" && $.trim(form.find("#remind_days").val()) == 0) {
        alert('提示:\n\n请选择发送时间');
        return false;
    } else if ($.trim(form.find("#remind_content").val()) == "") {
        alert('提示:\n\n内容不能为空');
        return false;
    } else if ($.trim(form.find("#remind_reseve_time").val()) <= todays && $.trim(form.find("#remind_days").val()) <= 0) {
        alert('提示:\n\n请选择正确时间');
        return false;
    }
}

function check_record_nonempty(obj) {
    if ($.trim($("input[name='records_title']").val()).length == 0) {
        tishi_alert('提示:\n\n名称不能为空');
        return false;
    } else if ($.trim($("textarea[name='records_content']").val()).length == 0) {
        tishi_alert('提示:\n\n内容不能为空');
        return false;
    }
}

