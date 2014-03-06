#encoding: utf-8
class PositionTypesController < ApplicationController
    before_filter :get_company

  def index
    @position_types = @company.position_types
  end
end