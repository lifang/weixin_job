$(function(){
	
	$(".leftMenu").css("height",$(document).height() - 84 +"px");
	
	$(".menuMakerDtl").css("height",$(document).height() - 168 +"px");
	
	$(".resumeDownloadDtl").css("height",$(document).height() - 168 +"px");
	
	$(".third_box .close").click(function(){
		$(this).parents(".third_box").hide();
		$(".third_bg").hide();
	});
	
	$("body").on("click",".thd_btn",function(){
		$(".third_bg").show();
		$(".third_box."+$(this).attr("name")).attr("to",$(this).parents(".second_box").attr("class"));
		$(".third_box."+$(this).attr("name")).show();
	});
	
	$(".second_box .close, .second_box .cancel").click(function(){
		if(!$(this).parents(".second_box").hasClass("third_box")){
			$(this).parents(".second_box").hide();
			$(".second_bg").hide();
		}
		
	});
	
	$("body").on("click",".scd_btn",function(){
		$(".second_bg").show();
		$(".second_box."+$(this).attr("name")).show();
	});
	
	$("tr").each(function(){
		var table = $(this).parents("table");
		var i = table.find("tr").index($(this));
		if(i % 2 ==1 && i != 0){
			$(this).css("background","#dcdada");
		}
	});
})