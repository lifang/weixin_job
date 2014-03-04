#encoding: utf-8
class SettingsController < ApplicationController
  def index

  end

  def update
    hash = {:name => params[:comp_name], :cweb => params[:comp_cweb], :has_app => params[:comp_has_app].to_i==0 ? false : true,
      :app_account => params[:comp_has_app].to_i==0 ? nil : params[:comp_app_count],
      :app_password => params[:comp_has_app].to_i==0 ? nil : params[:comp_app_password],
      :company_account => params[:comp_account], :company_password => params[:comp_password]}
    if @company.update_attributes(hash)
      flash[:notice] = "设置成功!"
    else
      flash[:notice] = @company.errors.messages.values.flatten.join("\\n")
    end
    redirect_to company_settings_path(@company)
  end

end
