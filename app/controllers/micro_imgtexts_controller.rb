#encoding:utf-8
class MicroImgtextsController < ApplicationController
  before_filter :has_sign?
  before_filter :get_company
  
  def new
    @micro_message = MicroMessage.find_by_id(params[:micro_message_id])
    @micro_imgtext = MicroImgtext.new
    render :edit
  end

  def edit
    @micro_imgtext = MicroImgtext.find(params[:id])
    @micro_message = @micro_imgtext.micro_message
  end

  def destroy
    @micro_imgtext = MicroImgtext.find(params[:id])
    @micro_message = @micro_imgtext.micro_message
    original_img_true_path = Rails.root.to_s+"/public"+ @micro_imgtext.img_path
    if @micro_imgtext && @micro_imgtext.destroy
      destroy_Original_img original_img_true_path  #删除对应文件
      flash[:notice] = "删除成功"
      redirect_to edit_compamy_micro_message_path(@company, @micro_message)
    else
      @micro_imgtexts = @micro_message.micro_imgtexts
      render "/micro_messages/edit"
    end
  end

end
