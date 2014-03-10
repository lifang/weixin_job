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
    sheet1.row(0)[0] = Spreadsheet::Link.new './images/1.jpg', "test"
    file_path = (get_company_dir_path @company.id.to_s)+"/excel/export.xls"
    FileUtils.rm file_path if File.exists?(file_path)
    book.write file_path
  end
  
  def xls_content_for(objs)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "form_datas_#{page}"
    arr =[]
    objs[0].hash_content.each do |ob|
      ob[1].each do |a|
        if a[1].class == Hash
          arr << a[1].keys[0]
        else
          arr << "头像链接"
        end
      end
    end
    sheet1.row(0).concat arr
    count_row = 1
    objs.each do |obj|
      i=0
      obj.hash_content.each do |ob|
        ob[1].each do |a|
          if a[1].class == Hash
            sheet1[count_row, i]= (a[1].values[0].is_a?(Array) ? a[1].values[0].join(",") : a[1].values[0]) if a[1].values[0]
          elsif a[0]=="headimage"
            sheet1.row(count_row)[i] = Spreadsheet::Link.new "file://./#{a[1]}", "他的头像"
          end
          i+=1
        end
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
