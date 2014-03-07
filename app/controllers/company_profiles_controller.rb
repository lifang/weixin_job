class CompanyProfilesController < ApplicationController
  before_filter :get_company
  def index
  end
  def new

  end
  def upload_img
    @image = params[:image]
    @root_path = Rails.root.to_s + "/public/companies/"+@company.name+"/company_profiles"
    FileUtils.mkdir_p @root_path unless Dir.exist?(@root_path)
    @full_path = @root_path +"/"+ @image.original_filename
    file1=File.new(@full_path,'wb')
    FileUtils.cp @image.path,file1
  end
end
