$(function(){
    
    $("#close_flash").click(function() {
        $("#flash_field").hide();
        $(".tab_alert").hide();
    });
    $("#flash_field").fadeOut(3000);



    $(".leftMenu").css("height",$(document).height() - 84 +"px");
	
    $(".second_box .close").click(function(){
        $(this).parents(".second_box").hide();
        $(".second_bg").hide();
    });
	
    $("body").on("click",".scd_btn",function(){
        $(".second_bg").show();
        $(".second_box."+$(this).attr("name")).show();
    });

    $("body").on("click",".userHead",function(){
        $(".second_bg").show();
        $(".second_box.addHeadImageItem").show();
    });

    $("body").on("click",".annex",function(){
        $(".second_bg").show();
        $(".second_box.addFileItem").show();
    });

    $("tr").each(function(){
        var table = $(this).parents("table");
        var i = table.find("tr").index($(this));
        if(i % 2 ==1 && i != 0){
            $(this).css("background","#dcdada");
        }
    });
})