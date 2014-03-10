#encoding:utf-8
class AppManagementsController < ApplicationController
  before_filter :has_sign?
  before_filter  :get_company
  skip_before_filter :has_sign?, :only => [:get_token, :submit_redirect]
  
  def index
    @client = Client.where("company_id=? and types = #{Client::TYPES[:ADMIN]}" , @company.id)[0]
    @chi =ClientHtmlInfo.find_by_client_id(@client.id) if @client
    @record = Record.find_by_company_id(@company.id)
    @record = Record.new unless @record
    @remind = Remind.find_by_company_id(@company.id)
    @remind = Remind.new unless @remind
  end

  def submit_redirect
    render :layout => false
  end

  #get form authenticity_token  hack of CSRF
  def get_token
    render :text => form_authenticity_token
  end
  
  def create_client_info_model
    @client = Client.where("company_id=? and types = #{Client::TYPES[:ADMIN]}" , @company.id)[0]
    @chi = ClientHtmlInfo.find_by_client_id(@client.id)
    tags = params[:tags].select {|k, v| k.include?("tag")} #标签
    optional_fields = params[:tags]  #"tags"=>{"message_1"=>{"name"=>"ree"}, "radio_1"=>{"name"=>"浜屼綅", "options"=>["鐑?, "璇烽棶", "浜?]}, "checkbox_1"=>{"name"=>"浜?璁╀粬", "options"=>["绐佺劧", "涓?, "濂?]}, "select_1"=>{"name"=>"钀ㄨ揪", "options"=>["椋?, "濂藉嚑涓?, "鐟炵壒"]}}}
    Client.transaction do
      if @chi
        if @chi.update_attributes({html_content:params[:html_content], hash_content: optional_fields})
          save_tags tags
          content = html_content_app(optional_fields)
          save_as_app_form content
          flash[:success]="保存成功"
          redirect_to company_app_managements_path(@company)
        else
          render 'index'
        end
      else
        ClientHtmlInfo.create(client_id:@client.id , html_content:params[:html_content], hash_content: optional_fields)
        save_tags tags
        redirect_to company_app_managements_path(@company)
      end
    end
  end
  
  #保存标签
  def save_tags tags
    tags.each  do |tag_key, name_and_options|
      name_and_options[:options].each do |tag_name|
        tag = Tag.find_by_content_and_company_id(tag_name, @company.id)
        @company.tags.create(:content => tag_name) unless tag
      end
    end
  end

  #得到表单数据
  def get_form_date
    app_client = params[:app_client]
    gzh_client = Client.where("company_id=? and types = #{Client::TYPES[:ADMIN]}" , @company.id)[0]
    client_html_info = gzh_client.client_html_info if gzh_client
    new_hash = {}
    app_client.each do |k, v|
      new_key = get_actual_name(k, client_html_info)
      new_hash[new_key] = v if new_key.present?
    end if app_client.present? && client_html_info
    open_id = params[:open_id]
    Client.transaction do
      if open_id.present?
        @client = Client.find_by_open_id(open_id)
        @company = Company.find_by_id(params[:company_id].to_i)
        if @client
          @client.update_attributes(params[:client].merge(html_content:new_hash))
          save_labels @client,@company.id ,params[:tags] if params[:tags].present?
          render text:2
        else
          client = Client.create(params[:client].merge(company_id:params[:company_id], html_content:new_hash ,types:Client::TYPES[:CONCERNED],open_id:open_id,
              has_new_record:false, has_new_message:false))
          save_labels client,@company.id, params[:tags] if params[:tags].present?
          render text:1
        end
      else
        render text:3
      end
    end
  end

  #根据表单元素name，获取对应的实际元素名称
  def get_actual_name(key, client_html_info)
    name = ""
    client_html_info.hash_content.each do |k, v|
      if k == key
        name = v["name"]
        break
      end
    end
    name
  end
  
  #将用户有的信息存入labels里面
  def save_labels client, company_id, tags
    all_tags = tags.values.flatten
    tags = Tag.where(:company_id => company_id, :content => all_tags)
    client.tags = tags
  end

  #保存app登记 文件
  def save_as_app_form content
    company_path = Rails.root.to_s + "/public/companies/#{@company.id}"
    path = Rails.root.to_s + "/public/companies/#{@company.id}/app_regist.html"
    FileUtils.mkdir_p(company_path) unless Dir.exists?(company_path)
    FileUtils.rm path if File::exist?(path)
    File.open(path, "wb") do |f|
      f.write(content.html_safe)
    end
  end

  #提交成功后跳转页面
  def submit_redirect
    render :layout => false
  end

  #生成html页面string
  def html_content_app(optional_fields)
    ele = ""
    optional_fields.each do |ele_type_name, label_and_options|
      ele_type_name

      # input
      if ele_type_name.include?("message")
        ele += "<div class='infoItem itemBox'>
                        <div><label>#{label_and_options[:name]}</label><input type='text' name='app_client[#{ele_type_name}]'/></div>
                </div>"
        #单选
      elsif ele_type_name.include?("radio")
        radio=""
        label_and_options[:options].each do |value|
          radio += "<div><input type='radio' name='app_client[#{ele_type_name}]' value=#{value} /><span>#{value}</span></div>"
        end
        ele += "<div class='radioItem itemBox'>
                    <div><span>#{label_and_options[:name]}</span></div>
                      #{radio}
                </div>"
        
        #多选~~~
      elsif ele_type_name.include?("checkbox")
        checkbox = ""
        label_and_options[:options].each do |value|
          checkbox += "<div><input type='checkbox' name='app_client[#{ele_type_name}][]' value=#{value} /><span>#{value}</span></div>"
        end
        ele += " <div class='checkItem itemBox'>
                    <div><span>#{label_and_options[:name]}</span></div>
                        #{checkbox}
                </div>"
        #标签
      elsif ele_type_name.include?("tag")
        checkbox = ""
        label_and_options[:options].each do |value|
          checkbox += "<div><input type='checkbox' name='tags[#{ele_type_name}][]' value=#{value} /><span>#{value}</span></div>"
        end
        ele += "<div class='checkItem itemBox'>
                    <div><span>#{label_and_options[:name]}</span></div>
                        #{checkbox}
                </div>"
        #下拉框
      elsif ele_type_name.include?("select")
        select = ""
        label_and_options[:options].each do |value|
          select += "<option value='#{value}'>#{value}</option>"
        end

        ele += "<div class='selectItem itemBox'>
                  <label>#{label_and_options[:name]}</label>
                 <select name=app_client['#{ele_type_name}']>#{select}</select>
        "
      end
    end

    html="
     <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml'>
    <head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
        <script src='/companies/js/jquery-1.8.3.js' type='text/javascript'></script>
        <link href='/companies/style/style2.css' rel='stylesheet' type='text/css' />
        <title>用户登记</title>
    </head>
    <body>
        <div class='form_list'>
               <form action='/companies/#{@company.id}/app_managements/get_form_date'  method='post'>
                  <div style='margin:0;padding:0;display:inline'>
                  <input name='utf8' type='hidden' value='&#x2713;' />
                  <input class='authenticity_token' name='authenticity_token' type='hidden' value='' /></div>
                    <div class='infoItem itemBox'>
                        <div><label><span class='mark'>*</span>姓名：</label><input type='text' data-name='姓名' class='client_required' name='client[name]'/></div>
                    </div>
                    <div class='infoItem itemBox'>
                        <div><label><span class='mark'>*</span>手机号码：</label><input type='text' data-name='手机号码' class='client_required' name='client[mobiephone]' /></div>
                    </div>
                    <div class='infoItem itemBox'>
                        <div><label>备注：</label><input type='text' name='client[remark]'/></div>
                    </div>
                    #{ele}
               </form>
              <p class='warn'>带*内容爲必填项目，请你务必完成填写。对于你所填写的所有信息，我们将严格保密。</p>
              <div class='form_btn'><button type='button' onclick='submit_form(this)'>确认提交</button></div>
        </div>

       <script>
          function submit_form(obj){
            var input =$(obj).parents('form').find('input.client_required');
            name = $.trim(input.val());
            label = input.attr('data-name')
            if(name==''){
              alert(label + '不能为空！');
              return false;
            }

            var href = window.location.href;
            var arr = href.split('?secret_key=');
            var secret_key = arr[1];

            var str = $(obj).parents('form').serialize();
            if(secret_key != 'undefined' && $.trim(secret_key) != ''){
              str = str + '&open_id='+secret_key;
            }
            $.ajax({
                async : true,
                type : 'post',
                url : '/companies/#{@company.id}/app_managements/get_form_date',
                dataType : 'text',
                  data : str,
                  success : function(data) {
                  if(data==1)
                    window.location.replace('/submit_redirect');
                  else if(data==2)
                      window.location.replace('/submit_redirect');
                  else if(data==3)
                    alert('缺少参数!')
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
