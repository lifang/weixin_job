// JavaScript Document

//tab
function tabFunc(c,t){
	var win_width = $(window).width();
	var win_height = $(window).height();
	var doc_width = $(document).width();
	var doc_height = $(document).height();
	
	var layer_height = $(t).height();
	var layer_width = $(t).width();

	$(c).click(function(){
		$(t).css('display','block');
		$(t).css('top',(doc_height-$(window).scrollTop()-layer_height)/2);
		$(t).css('left',(win_width-layer_width)/2);
		return false;
	})

	$(".close").click(function(){
		$(this).parents(t).css("display","none");
	});
}
$(function(){
	tabFunc("a.preview_icon",".tab");	
})

//登录默认值
function focusBlur(e){
	$(e).focus(function(){
		var thisVal = $(this).val();
		if(thisVal == this.defaultValue){
			$(this).val('');
		}	
	})	
	$(e).blur(function(){
		var thisVal = $(this).val();
		if(thisVal == ''){
			$(this).val(this.defaultValue);
		}	
	})	
}

$(function(){
	focusBlur('.login_box input');//登录input默认值
})

//计算页面高度
$(function(){
	var ch = document.documentElement.clientHeight-40;
	$(".left").css("min-height",ch);
	$(".right").css("min-height",ch);
	
	$(".content").css("min-height",$(".right").height()-135-$(".title").height());
})

//nav 
$(function(){
	$(".nav_list p").click(function(){
		$(".nav_list").removeClass("hover");
		$(this).parent().addClass("hover");
		if(!$(this).parent().find("ul").is(":visible")){
			$(".nav_list ul").slideUp(300);
			$(this).parent().find("ul").slideDown(300);
		}
	});
})

//模拟select
$(function(){
	$(".select_tag").click(function() {
		$(this).parent(".select_box").find("ul").toggle();
	});
	$(".select_box ul li").click(function() {
		$(this).addClass("hover").siblings().removeClass("hover");
		var text = $(this).html();
		var $val = $(this).find("input").val();
		$(this).parents(".select_box").find(".select_tag span").html(text);
		$(this).parents(".select_box").find("input.tag_input").val($val);
		
		$(this).parents(".select_box").find("ul").hide();
	});
	
	$(document).bind('click', function(e) {
		var $clicked = $(e.target);
		if (! $clicked.parents().hasClass("select_box"))
		$(".select_box ul").hide();
		
	});

})


//tooltip-内容提示
$(function(){
	var x = 0;
	var y = 20;
	$(".tooltip_html").mouseover(function(e){
		this.myTitle=$(this).html();
		
		var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";
		$("body").append(tooltip);
		$(".tooltip_box").css({
			"top":(e.pageY+y)+"px",
			"left":(e.pageX+x)+"px"
		}).show("fast");
	}).mouseout(function(){
		
		$(".tooltip_box").remove();
	}).mousemove(function(e){
		$(".tooltip_box").css({
			"top":(e.pageY+y)+"px",
			"left":(e.pageX+x)+"px"
		})
	});
})
//tooltip-title提示
$(function(){
	var x = 0;
	var y = 20;
	$(".tooltip_title").mouseover(function(e){
		this.myTitle=this.title;
		this.title="";
		var tooltip = "<div class='tooltip_box'><div class='tooltip_next'>"+this.myTitle+"</div></div>";
		
		$("body").append(tooltip);
		$(".tooltip_box").css({
			"top":(e.pageY+y)+"px",
			"left":(e.pageX+x)+"px"
		}).show("fast");
	}).mouseout(function(){
		this.title = this.myTitle;
		$(".tooltip_box").remove();
	}).mousemove(function(e){
		$(".tooltip_box").css({
			"top":(e.pageY+y)+"px",
			"left":(e.pageX+x)+"px"
		})
	});
})

/*manage_body 切换 管理简历*/
$(function(){
	$(".manage_head li:first").addClass("hover");
	$(".manage_body > div").not(":first").hide();
	$(".manage_head li").unbind("click").bind("click", function(){
		$(this).addClass("hover").siblings().removeClass("hover");
		var index = $(".manage_head li").index( $(this) );
		$(".manage_body > div").eq(index).fadeIn("slow").siblings().hide();
   });
})

//table偶数行变色
$(function(){
	$(".b_table > tbody > tr:odd").addClass("tbg");
});