#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  before_filter :get_company
  def index
    @positions = @company.positions
  end

  def edit

  end

  def update

  end
  
  def new
    @position = @company.posotions.built
  end

  def create

  end

  def release   #发布

  end

  def destroy
    
  end
end
