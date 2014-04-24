#encoding: utf-8
class WeixinRepliesController < ApplicationController
  before_filter :has_sign?
  before_filter  :get_company
  before_filter :get_imgtexts, :only => [:new, :edit]
  
  def index
    @title = "自动回复"
    if params[:search_wx]  #搜索关键詞
      @content = search_content(params[:search_wx])
      @key_replies = @company.keywords.where("keyword like (?)","%#{@content}%" ).paginate(:per_page => 9, :page => params[:page])
      @flag = "search"
    else
      @flag = "index"
      #关注后回复
      @auto_reply = @company.keywords.auto[0]
      @auto_micro_message = @auto_reply.micro_message if @auto_reply
      @auto_micro_imagetexts = @auto_micro_message.micro_imgtexts if @auto_micro_message

      #关键詞回复
      @key_replies = @company.keywords.keyword.paginate(:per_page => 9, :page => params[:page])
    end

    key_micro_messages = MicroMessage.where(:id => @key_replies.map(&:micro_message_id))
    @key_micro_imagetexts = MicroImgtext.where(:micro_message_id => key_micro_messages.map(&:id)).group_by{|mm| mm.micro_message_id}
  end

  def new
    @title = "自动回复"
    @keyword = @company.keywords.new
  end

  def edit
    @title = "自动回复"
    @keyword = Keyword.find_by_id params[:id]
    if @keyword
      @micro_message = @keyword.micro_message
      @this_micro_imagetexts = @micro_message.micro_imgtexts if @micro_message
    end
  end

  def destroy
    keyword = Keyword.find_by_id params[:id]
    micro_message = keyword.micro_message
    if micro_message && micro_message.text?
      micro_message.destroy
    end
    keyword.destroy
    flash[:notice] = "删除成功"
    redirect_to company_weixin_replies_path(@company)
  end

  def create
    micro_message_id, text, keyword, solid_link_flag = params[:micro_message_id], params[:content], params[:keyword], params[:solid_link_flag] #图文消息，文字消息， 自动回复(auto)/关键字回复(keyword) 关键字  刮刮乐/app
    begin
      Keyword.transaction do
        if text.present? #文字回复
          micro_message = @company.micro_messages.create(:mtype => MicroMessage::TYPE[:text], :solid_link_flag => solid_link_flag.present? ? (solid_link_flag == "ggl" ? 0 : 1) : nil)
          micro_message_id = micro_message.id if micro_message
          micro_message.micro_imgtexts.create(:content => text ) if micro_message
        end
        if keyword.blank?  #自动回复
          auto_message = @company.keywords.auto[0]
          if auto_message.present?
            auto_message.update_attribute(:micro_message_id, micro_message_id)
          else
            @company.keywords.create(:micro_message_id => micro_message_id, :types => Keyword::TYPE[:auto])
          end
        else #关键字回复
          @company.keywords.create(:micro_message_id => micro_message_id, :keyword => keyword, :types => Keyword::TYPE[:keyword])
        end
        
      end
      flash[:notice] = "保存成功"
      redirect_to company_weixin_replies_path(@company)
    rescue
      render :new
    end
  end

  def update  #关键字更新
    micro_message_id, text,keyword_param,@index, solid_link_flag = params[:micro_message_id], params[:content], params[:keyword], params[:index].to_i, params[:solid_link_flag] #图文消息，文字消息， 自动回复(auto)/关键字回复(keyword) 关键字 li索引 刮刮乐/app
    begin
      Keyword.transaction do
        @keyword = Keyword.find_by_id params[:id]
        micro_message = @keyword.micro_message
        #关键詞回复
        if text.present? #文字回复
          if micro_message && micro_message.text? #原来就是文字回复，更新
            p 111111111111111111
            micro_message.update_attribute(:solid_link_flag, solid_link_flag.present? ? (solid_link_flag == "ggl" ? 0 : 1) : nil) #如果是刮刮乐或者app 更新micro_message
            micro_message.micro_imgtexts[0].update_attribute(:content, text) if micro_message.micro_imgtexts[0]
            @keyword.update_attributes({:keyword => keyword_param})
          else  #原来是图文回复，新建文字回复
            p 2222222222222222222222
            micro_message = @company.micro_messages.create(:mtype => MicroMessage::TYPE[:text], :solid_link_flag => solid_link_flag.present? ? (solid_link_flag == "ggl" ? 0 : 1) : nil)
            micro_message.micro_imgtexts.create(:content => text ) if micro_message
            @keyword.update_attributes({:micro_message_id => micro_message.id, :keyword => keyword_param})
          end
        else #图文回复
          if micro_message && micro_message.text?  #原来是文字，删除原来消息
            micro_message.destroy
          end
          #根据传过来的图文id更新关键字
          @keyword.update_attributes({:micro_message_id => micro_message_id, :keyword => keyword_param})
        end
        key_micro_message = @keyword.micro_message
        @key_micro_imagetexts = MicroImgtext.where(:micro_message_id => key_micro_message).group_by{|mm| mm.micro_message_id}
      end
      flash[:notice] = "保存成功"
      redirect_to company_weixin_replies_path(@company)
    rescue
      render :edit
    end
  end

  private
  
  def get_imgtexts
    #所有图文消息
    micro_messages = @company.micro_messages.image_text
    @micro_imagetexts = MicroImgtext.where(:micro_message_id => micro_messages.map(&:id)).group_by{|mm| mm.micro_message_id}
    #app登记
    @app_link = "/companies/#{@company.id}/app_managements/app_regist" if @company.has_app
  end
end