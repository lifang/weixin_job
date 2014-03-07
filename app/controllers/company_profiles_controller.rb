class CompanyProfilesController < ApplicationController
  before_filter :has_sign?
  before_filter :get_title
  def index
  end
  def new

  end

  def get_title
    @title = "公司简介"
  end
end
