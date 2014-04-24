$(function(){
	
    $(".leftMenu").css("height",document.body.scrollHeight - 84 +"px");

    $(".menuMakerDtl").css("height",document.body.scrollHeight - 168 +"px");

    $(".resumeDownloadDtl").css("height",document.body.scrollHeight - 168 +"px");
	
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
            //$(this).css("background","#dcdada");
        }
    });
    $("#close_flash").click(function() {
        $("#flash_field").hide();
        $(".tab_alert").hide();
    });
    $("#flash_field").fadeOut(2000);

    $(".profileExplain").on("click","li",function(){
        if($(this).hasClass("open")){
            $(this).removeClass("open");
        }else {
            $(".profileExplain li").removeClass("open");
            $(this).addClass("open");
            //点击后重新计算左侧侧边栏以及整个高度
             $(".leftMenu").css("height",document.body.scrollHeight - 84 +"px");
             $(".menuMakerDtl").css("height",document.body.scrollHeight - 168 +"px");
        }
    });
    $(".leftMenuItem").click(function(){
		if($(this).hasClass("hover")){
			$(this).toggleClass("hover");
		}else{
			$(".leftMenuItem").removeClass("hover");
			$(this).toggleClass("hover");
		}
	});
})

//提示错误信息
function tishi_alert(message) {
    $(".alert_h").html(message);
    var tab = $(".tab_alert");
    var scolltop = document.body.scrollTop | document.documentElement.scrollTop;
    //滚动条高度
    var win_height = $(document).height();
    var z_layer_height = $(".tab_alert").height();
    tab.css('top', 100 + scolltop);
    var doc_width = $(document).width();
    var layer_width = $(".tab_alert").width();
    tab.css('left', (doc_width - layer_width) / 2);
    tab.css('display', 'block');
    tab.fadeTo("slow", 1);
    $(".tab_alert .close_s").click(function() {
        tab.css('display', 'none');
    })
    setTimeout(function() {
        tab.fadeTo("slow", 0);
    }, 4000);
    setTimeout(function() {
        tab.css('display', 'none');
    }, 4000);

}