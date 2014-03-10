#encoding:utf-8
class AppManagementsController < ApplicationController
  layout 'sites'
  before_filter :get_site,:exist_app?
  skip_before_filter :authenticate_user!,:get_site,:exist_app? ,only:[:get_form_date, :submit_redirect]
  def index
    @client = Client.where("site_id=? and types = 0" , @site.id)[0]
    @chi =ClientHtmlInfo.find_by_client_id(@client.id) if @client
    @record = Record.find_by_site_id(@site.id)
    @remind = Remind.find_by_site_id(@site.id)
  end

  def submit_redirect
    render :layout => false
  end

  def create_client_info_model
    @client = Client.where("site_id=? and types = 0" , @site.id)[0]
    @chi=ClientHtmlInfo.find_by_client_id(@client.id)
    form = params[:form]
    if @chi
      if @chi.update_attribute(:hash_content,params[:html_content])
        save_tags form
        content = html_content_app form
        save_as_app_form content
        flash[:success]="保存成功"
        redirect_to site_app_managements_path(@site)
      else
        render 'index'
      end
    else
      ClientHtmlInfo.create(client_id:@client.id , hash_content:params[:html_content])
      save_tags form
      redirect_to site_app_managements_path(@site)
    end
  end
  #保存标签
  def save_tags form
    form.each_with_index do |f,index|
      if f[0][1..-1]=="label"
        value =f[1][:value]
        value.each do |v|
          val=Tag.find_by_content(v)
          if val.nil?
            Tag.create(content:v)
          end
        end
      end
    end
  end
  #得到表单数据
  def get_form_date
    form = params[:form]
    form_hash ="{"
    form.each_with_index do |f,index|
      if index>2
        value =f[1][:value]
        if f[1][:value].class.eql?(Array)
          value = f[1][:value].join("、")
        end
       
        form_hash +="'#{f[1][:name]}'=>'#{value}',"
        
      end
    end
    form_hash = form_hash[0...-1]+"}"
    @client = Client.find_by_open_id(params[:open_id])
    open_id = params[:open_id]
    @site = Site.find_by_id(params[:site_id].to_i)
    cweb = @site.cweb if @site
    if @client
      user_head_image_url = get_user_basic_info(open_id, cweb) if cweb.present? && open_id.present?
      @client.update_attributes(name:params[:username] , mobiephone:params[:phone],remark:params[:remark],site_id:params[:site_id] , html_content:form_hash, avatar_url: user_head_image_url )
      save_labels @client,params[:site_id] ,form
      render text:2      
    else
      user_head_image_url = get_user_basic_info(open_id, cweb) if cweb.present? && open_id.present?
      client = Client.create(name:params[:username], mobiephone:params[:phone] ,site_id:params[:site_id], html_content:form_hash ,types:Client::TYPES[:CONCERNED],open_id:open_id,
        has_new_record:false, has_new_message:false, avatar_url: user_head_image_url)
        save_labels client,params[:site_id],form
      render text:1
    end
  end
  #将用户有的信息存入labels里面
  def save_labels client,site_id,form
    
    Label.where("client_id = ? and site_id= ?" , client.id , site_id).destroy_all
    form.each_with_index do |f,index|
      if f[0][1..-1]=="label"
        value =f[1][:value]
        unless value.nil?
        value.each do |v|
          tag =Tag.find_by_content(v)
          label = Label.where("client_id = ? and site_id= ? and tag_id=?" , client.id , site_id , tag.id)[0]
          if label.nil?
            Label.create(site_id:site_id,client_id:client.id,tag_id:tag.id)
          end
        end
        end
      end
    end
  end
  
  def save_as_app_form content
    site_path = Rails.root.to_s + "/public/allsites/#{@site.root_path}"
    path = Rails.root.to_s + "/public/allsites/#{@site.root_path}/this_site_app.html"
    FileUtils.mkdir_p(site_path) unless Dir.exists?(site_path)
    FileUtils.rm path if File::exist?(path)
    File.open(path, "wb") do |f|
      f.write(content.html_safe)
    end
  end
  def html_content_app form
    li=""
    form.each_with_index do |element,index|
      ele = element[0][1..-1]
      if ele.eql?("text")
        li += "<li><label>" + ((index==0 || index==1) ? "<span class='mark'>*</span>" : "") + "#{element[1][:name]}：<input name='form[t#{index}][name]' type='hidden' value='#{element[1][:name]}' /> </label><input name='form[t#{index}][value]' type='text'></li>"
        
        #单选
      elsif ele.eql?("radio")
        radio=""
        element[1][:value].each do |value|
          radio +="<li><input name='form[r#{index}][value]' type='radio' value='#{value}'/><p>#{value}</p></li>
          "
        end
        li += "<li><label>#{element[1][:name]}<input name='form[r#{index}][name]' type='hidden' value='#{element[1][:name]}' /></label> </li>#{radio}
        "
        
        #多选~~~
      elsif ele.eql?("checkbox")
        checkbox=""
        element[1][:value].each do |value|
          checkbox +="<li><input name='form[c#{index}][value][]' type='checkbox' value='#{value}' /><p>#{value}</p></li>
          "
        end
        li += "<li><label>#{element[1][:name]}<input name='form[c#{index}][name]' type='hidden' value='#{element[1][:name]}' /></label></li>#{checkbox}
        "
      elsif ele.eql?("label")
        checkbox=""
        element[1][:value].each do |value|
          checkbox +="<li><input name='form[#{index}label][value][]' type='checkbox' value='#{value}' /><p>#{value}</p></li>
          "
        end
        li += "<li><label>#{element[1][:name]}<input name='form[#{index}label][name]' type='hidden' value='#{element[1][:name]}' /></label></li>#{checkbox}
        "
      elsif ele.eql?("select")  
        select =""
        element[1][:value].each do |value|
          select +="<option  value='#{value}'>#{value}</option>
          "
        end
        li += "<li><label>#{element[1][:name]}：<input name='form[s#{index}][name]' type='hidden' value='#{element[1][:name]}' /></label><select name='form[s#{index}][value]'>#{select}</select>
        "
      end
    end
    html="
     <!doctype html>
<html>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no'>
<title>客户表单</title>
<script type='text/javascript' src='/allsites/js/jQuery-v1.9.0.js'></script>
<script src='http://malsup.github.com/jquery.form.js'></script> 
<link href='/allsites/style/template_style.css' rel='stylesheet' type='text/css'>


</head>

<body>
  <article>
        <section class='app_form'>
        <form action='/sites/#{@site.id}/app_managements/get_form_date' data-remote='true' data-type='script' method='post'>
          <div style='margin:0;padding:0;display:inline'>
          <input name='utf8' type='hidden' value='&#x2713;' />
          <input class='authenticity_token' name='authenticity_token' type='hidden' value='' /></div>
          <ul>
               #{li}
            </ul>
     <p class='warn'>带*内容爲必填项目，请你务必完成填写。对于你所填写的所有信息，我们将严格保密。</p>
            <div class='form_btn'><button type='button' onclick='submit_form(this)'>确认提交</button></div>
        </form>
        </section>
    </article>
<script type='text/javascript' src='/allsites/js/template_main.js'></script>
    <script>
      function submit_form(value){
        var input =$('.app_form').find('input[type=text]');
        name = $.trim($(input[0]).val());
        if(name==''){
          alert('请输入姓名');
          return false;
        }
        phone = $.trim($(input[1]).val());
        if(phone==''){
          alert('请输入电话');
          return false;
        }
        remark = $.trim($(input[2]).val());
        var href = window.location.href;
        var arr = href.split('?open_id=');
        var open_id = arr[1];
        var str = $(value).parent().parent().serialize();
        $.ajax({
    async : true,
    type : 'post',
    url : '/sites/#{@site.id}/app_managements/get_form_date',
    dataType : 'text',
    data :'form = ' + str+'&username='+name+'&phone='+phone+'&remark='+remark+'&open_id='+open_id,
    success : function(data) {
      if(data==1)
        window.location.replace('/submit_redirect');
      else if(data==2)
        window.location.replace('/submit_redirect');
      else
        alert('error');
    }
  });
    
      }
    </script>
    <script language='javascript' type='text/javascript'>
        $.ajax({

            url: '/get_token',
            type: 'get',
            dataType: 'text',
            success:function(data){
var a = $('.authenticity_token');
a.each(function(){
  $(this).val(data);
});
            },
            error:function(data){
//alert('error')
            }
        })
</script>
</body>
</html>

    "
    html
  end
end
