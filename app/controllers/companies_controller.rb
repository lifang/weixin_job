#encoding: utf-8
class CompaniesController < ApplicationController
  before_filter :has_sign?
  before_filter :get_title
  def show
    @company = Company.find_by_id(params[:company_id].to_i)
  end

  def update
    Company.transaction do
      @company = Company.find_by_id(params[:company_id].to_i)
      edit_type = params[:edit_type].to_i
      if edit_type == 0
        hash = {:name => params[:company_name], :cweb => params[:company_cweb], :app_type => params[:app_type].to_i,
          :app_id => params[:company_app_id], :app_secret => params[:company_app_secret]}
        if @company.update_attributes(hash)
          flash[:notice] = "设置成功!"
        else
          flash[:notice] = @company.errors.messages.values.flatten.join("\\n")
        end
      elsif edit_type == 1
        hash = {:has_app => params[:has_app].to_i==0 ? false : true,
          :app_account => params[:has_app].to_i==0 ? nil : params[:company_app_account].strip,
          :app_password => params[:has_app].to_i==0 ? nil : Digest::MD5.hexdigest(params[:company_app_password].strip)
        }
        if @company.update_attributes(hash)
          #创建client 开始
          client = @company.clients.where("types = #{Client::TYPES[:ADMIN]}")[0]
          if client
            client.update_attributes(:app_account => params[:has_app].to_i==0 ? nil : params[:company_app_account].strip,
              :app_password => params[:has_app].to_i==0 ? nil : Digest::MD5.hexdigest(params[:company_app_password].strip))
          else
             @company.clients.create(:username => params[:has_app].to_i==0 ? nil : params[:company_app_account].strip,
              :password => params[:has_app].to_i==0 ? nil : Digest::MD5.hexdigest(params[:company_app_password].strip),
               :types => Client::TYPES[:ADMIN])
          end
          #创建client 结束
          flash[:notice] = "设置成功!"
        else
          flash[:notice] = @company.errors.messages.values.flatten.join("\\n")
        end
      end
      redirect_to "/companies/show?company_id=#{@company.id}"
    end
  end
  
  def get_title
    @title = "设置"
  end
end
