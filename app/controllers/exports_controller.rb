#encoding: utf-8
class ExportsController < ApplicationController   #导出简历
  before_filter :has_sign?
end
