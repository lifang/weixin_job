$(function(){
	
	$(".leftMenu").css("height",$(document).height() - 84 +"px");
	
	$(".second_box .close").click(function(){
		$(this).parents(".second_box").hide();
		$(".second_bg").hide();
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