#encoding:utf-8
class RemindsController < ApplicationController
  before_filter :get_company
  def create
    Remind.transaction do
      if params[:remind][:days].present?
        params[:remind][:reseve_time] = nil
      else
        params[:remind][:days] = nil
      end
      @remind = @company.reminds.create(params[:remind])
      if @remind
        flash[:notice] = "新建成功!"
        redirect_to "/companies/#{params[:company_id]}/app_managements"
      else
        @status = "remind_save_failed"
        flash[:notice] = "新建失败!  #{@remind.errors.messages.values.flatten.join("\\n")}"
        render :index
      end
    end
  end

  def update
    @remind = Remind.find_by_id(params[:id])
    if params[:remind][:days].present?
      params[:remind][:reseve_time] = nil
    else
      params[:remind][:days] = nil
    end
    if @remind.update_attributes(params[:remind])
      flash[:notice] = "更新成功!"
      redirect_to "/companies/#{params[:company_id]}/app_managements"
    else
      @status = "remind_save_failed"
      flash[:notice] = "更新失败!  #{@remind.errors.messages.values.flatten.join("\\n")}"
      render :index
    end
  end

  def message_record
    @record = Record.find_by_site_id(@site.id)
    @remind = Remind.find_by_site_id(@site.id)
  end
end
