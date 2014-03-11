#encoding:utf-8
class RecordsController < ApplicationController
  before_filter :get_company

  def create
    @record = @company.records.create(params[:record])
    Record.transaction do
      if @record
        flash[:notice] = "新建成功!"
        redirect_to "/companies/#{params[:company_id]}/app_managements"
      else
        @status = "record_save_failed"
        flash[:notice] = "新建失败! #{@record.errors.messages.values.flatten.join("\\n")}"
        render :index
      end
    end 
  end

  def update
    @record = Record.find_by_id(params[:id])
    Record.transaction do
      if @record.update_attributes(params[:remind])
        flash[:notice] = "更新成功!"
        redirect_to "/companies/#{params[:company_id]}/app_managements"
      else
        @status = "record_save_failed"
        flash[:notice] = "更新失败! #{@record.errors.messages.values.flatten.join("\\n")}"
        render :index
      end
    end
  end
end