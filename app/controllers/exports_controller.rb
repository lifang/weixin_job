#encoding: utf-8
class ExportsController < ApplicationController   #导出简历
  before_filter :has_sign?,only:[:index]
  before_filter  :get_company
  def index
    
  end
  def down_zip_file
    directory = get_company_dir_path @company.id.to_s+"/excel/"
 
    FileUtils.mkdir_p directory unless Dir.exists?(directory)
    zipfile_name =""
    if Dir.exists?(directory)
      zipfile_name = (get_company_dir_path @company.id.to_s)+"/excel/export.zip"
      if File.exists?(zipfile_name)
        FileUtils.rm_f zipfile_name
      end
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        Dir[File.join(directory, '**', '**')].each do |file|
          zipfile.add(file.sub(directory, ''), file)
        end
      end
    end
    send_file zipfile_name
  end
  def create_xsl_table
    start_time = params[:start_time]
    end_time = params[:end_time]
    @client_infos = (Company.get_client_infos_by @company.id.to_s,start_time,end_time) || []
    p @client_infos
    if @client_infos.length>0
      xls_content_for @client_infos
      render text:1
    else
      xls_content_fors
      render text:2
    end
  end

  def xls_content_fors
    p 21312312312
    book = Spreadsheet::Excel::Workbook.new
    sheet1 = book.create_worksheet :name => "form_datas_#{1312}"
    sheet1[0, 0]="<a href='http://www.baidu.com'>haah</a>"
    sheet1.row(0)[0] = Spreadsheet::Link.new './images/1.jpg', "wwwwwwwwwwww"
    file_path = (get_company_dir_path @company.id.to_s)+"/excel/export.xls"
    FileUtils.rm file_path if File.exists?(file_path)
    book.write file_path
  end
  
  def xls_content_for(objs)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "form_datas_#{page}"
    arr=[]
    objs[0].each do |ob|
      arr << ob.key
    end
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
    file_path = (get_company_dir_path @company.id.to_s)+"/excel/export.xls"
    FileUtils.rm file_path if File.exists?(file_path)
    book.write file_path
  end
  def get_company
    @company = Company.find_by_id(params[:company_id])

  end
end
