#encoding: utf-8
class SynopsisController < ApplicationController  #公司简介
  before_filter :has_sign?
end
