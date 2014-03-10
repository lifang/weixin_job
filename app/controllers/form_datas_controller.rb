#encoding: utf-8
class FormDatasController < ApplicationController

  #下载表单数据
  def index
    #page_id
    @page = Page.find_by_id params[:page_id]
    @form_datas = FormData.find_all_by_page_id(params[:page_id])
    respond_to do |format|
      format.xls {
        send_data(xls_content_for(@form_datas, @page),
          :type => "text/excel;charset=utf-8; header=present",
          :filename => "form_#{params[:page_id]}.xls")
      }
    end
  end

  private

  def xls_content_for(objs, page)
    
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "form_datas_#{page}"
    sheet1.row(0).concat page.element_relation.values
    count_row = 1
    objs.each do |obj|
      data_hash = obj.data_hash
      if data_hash.present?
        label_names = data_hash.keys.select{|key| !key.include?("value")}
        label_names.length.times {|i|
          data_value = data_hash[label_names[i]]
          sheet1[count_row, i] = (data_value.is_a?(Array) ? data_value.join(",") : data_value) if data_value
        }
        count_row += 1
      end
    end
    book.write xls_report
    xls_report.string
  end
end