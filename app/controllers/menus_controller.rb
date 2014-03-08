#encoding: utf-8
class MenusController < ApplicationController   #菜单
  before_filter :has_sign?
  before_filter :get_title
  def index
    @resume_tmp = ResumeTemplate.find_by_id(@company.id)
    @positions = Position.select("id,name").where(["company_id =? and status = ?", @company.id, Position::STATUS[:RELEASED]])
    p @positions
  end
  
  def get_title
    @title = "菜单"
  end
end
