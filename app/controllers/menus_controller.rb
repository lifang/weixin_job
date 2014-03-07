#encoding: utf-8
class MenusController < ApplicationController   #菜单
  before_filter :has_sign?
  before_filter :get_title

  def get_title
    @title = "菜单"
  end
end
