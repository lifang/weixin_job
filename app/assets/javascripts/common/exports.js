function create_xsl_table(obj,company_id){
    var date_time = $.trim($(obj).parent().find('.start').val());
	if (date_time == "") {
		 alert("时间不能为空");
		return false;
	}
        var date_time1 = $.trim($(obj).parent().find('.end').val());
        if (date_time1 == "") {
		 alert("时间不能为空");
		return false;
	}
        $.ajax({
            type:'get',
            url:"/companies/"+company_id+"/exports/create_xsl_table.xls",
            dateType: 'text',
            date:"start_time="+date_time+"&end_time="+date_time1,
            success: function(data) {
                if(data=="1"){
                    alert("导出成功！请下载");
                }else{
                    alert("暂无数据！");
                }

            }
        });
	
}