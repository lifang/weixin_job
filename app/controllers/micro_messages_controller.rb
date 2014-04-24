#encoding:utf-8
class MicroMessagesController < ApplicationController
  before_filter :has_sign?
  before_filter  :get_company
  
  def index
    @title = "图文消息"
    @content = params[:search_mme]
    if @content.present?
      @micro_messages = @company.micro_messages.image_text.includes(:micro_imgtexts)
      .where("micro_imgtexts.title like (?) or micro_imgtexts.content like (?)","%#{@content}%", "%#{@content}%")
      .paginate(:per_page => 8, :page => params[:page])
    else
      @micro_messages = @company.micro_messages.image_text
      .paginate(:per_page => 8, :page => params[:page])
    end
    micro_message_ids = @micro_messages.map(&:id)
    micro_imgtexts = MicroImgtext.where(:micro_message_id => micro_message_ids)
    if micro_imgtexts
      @micro_imgtexts = micro_imgtexts.group_by{|mm| mm[:micro_message_id]}
    end
  end

  def new
    @title = "图文消息"
    @micro_message = @company.micro_messages.new
    @micro_imgtext = MicroImgtext.new
  end
  
  def edit
    @title = "图文消息"
    @micro_message =MicroMessage.find_by_id(params[:id])
    @micro_imgtext = MicroImgtext.new
    @micro_imgtexts = @micro_message.micro_imgtexts
  end
  
  def create
    MicroMessage.transaction do
      @micro_message = @company.micro_messages.create(mtype:MicroMessage::TYPE[:image_text])
      file = params[:micro_message][:micro_imgtext][:img_path]
      params[:micro_message][:micro_imgtext].delete(:img_path)
      @micro_imgtext = @micro_message.micro_imgtexts.new(params[:micro_message][:micro_imgtext])
      json_return = MicroImgtext.save_and_return_file_path(file, @company) if file
      if json_return && json_return[:status] == 0
        @micro_imgtext.img_path = json_return[:file_path]
        if @micro_message && @micro_imgtext.save
          flash[:notice] = "模块添加成功"
          redirect_to edit_company_micro_message_path(@company, @micro_message)
        else
          render :new
        end
      else
        flash[:error] = json_return[:msg] if json_return
        params[:micro_message][:micro_imgtext][:img_path] = nil
        render :new
      end
    end
  end

  def update
    MicroMessage.transaction do
      @micro_message = MicroMessage.find_by_id(params[:id])
      file = params[:micro_message][:micro_imgtext][:img_path]
      params[:micro_message][:micro_imgtext].delete(:img_path)
      if params[:micro_imgtext_id].present?
        @micro_imgtext = MicroImgtext.find_by_id(params[:micro_imgtext_id])
        old_file_path = @micro_imgtext.img_path
      else
        @micro_imgtext = @micro_message.micro_imgtexts.new(params[:micro_message][:micro_imgtext])
      end
      json_return = MicroImgtext.save_and_return_file_path(file, @company) if file
      if json_return && json_return[:status] == 0
        @micro_imgtext.img_path = json_return[:file_path]
        if @micro_imgtext.save
          flash[:notice] = "模块添加成功"
          if old_file_path
            destroy_Original_img Rails.root.to_s+"/public"+ old_file_path
            flash[:notice] = "模块修改成功"
          end
          redirect_to edit_company_micro_message_path(@company, @micro_message)
        else
          @micro_imgtexts = @micro_message.micro_imgtexts
          render :edit
        end
      else
        flash[:error] = json_return[:msg] if json_return
        params[:micro_message][:micro_imgtext][:img_path] = nil
        @micro_imgtexts = @micro_message.micro_imgtexts
        render :edit
      end
    end
  end

  def destroy
    @micro_messages =MicroMessage.find_by_id(params[:id])
    if !@micro_messages.nil?
      @img_texts =@micro_messages.micro_imgtexts
      @img_texts.each do |img_text|
        original_img_true_path = Rails.root.to_s+"/public"+ img_text.img_path
        FileUtils.rm original_img_true_path if File::exist?( original_img_true_path )
        FileUtils.rm get_min1_by_imgpath original_img_true_path if File::exist?( get_min1_by_imgpath original_img_true_path )
        FileUtils.rm get_min2_by_imgpath original_img_true_path if File::exist?( get_min2_by_imgpath original_img_true_path )  
      end
      keyword = @micro_messages.keyword
      if keyword
        if keyword.auto?
          keyword.destroy
        else
          keyword.update_attribute(:micro_message_id, nil)
        end
      end
      @micro_messages.destroy
      flash[:success]="删除成功！"
      redirect_to company_micro_messages_path(@site)
    else
      flash[:success]="删除失败，不存在资源！"
      redirect_to company_micro_messages_path(@site)
    end
  end

end
