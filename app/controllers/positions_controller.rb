#encoding: utf-8
class PositionsController < ApplicationController   #招聘职位
  def index
    @positions = @company.positions
  end

  def edit

  end

  def update

  end
  
  def new

  end

  def create

  end

  def release   #发布

  end

  def destroy
    
  end
end
