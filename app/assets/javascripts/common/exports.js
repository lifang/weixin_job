function create_xsl_table(obj,company_id){
    var date_time = $.trim($(obj).parent().find('.start').val());
	if (date_time == "") {
		 tishi_alert("开始时间不能为空");
		return false;
	}
        var date_time1 = $.trim($(obj).parent().find('.end').val());
        if (date_time1 == "") {
		 tishi_alert("结束时间不能为空");
		return false;
	}
        var begin_time = new   Date(Date.parse(date_time.replace(/-/g,   "/")));
	var end_time = new   Date(Date.parse(date_time1.replace(/-/g,   "/")));
	if(end_time<begin_time){
		tishi_alert("结束时间不能早于开始时间！");
		return false;
	}
        $.ajax({
            type:'get',
            url:"/companies/"+company_id+"/exports/create_xsl_table.xls",
            dateType: 'text',
            data:"start_time="+date_time+"&end_time="+date_time1,
            success: function(data) {
                if(data=="1"){
                    tishi_alert("导出成功！请下载");
                }else{
                    tishi_alert("暂无数据！");
                }

            }
        });
	
}