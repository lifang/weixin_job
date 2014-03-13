#encoding: utf-8
class ExportsController < ApplicationController   #导出简历
  before_filter :has_sign?,only:[:index]
  before_filter  :get_company,:get_title
  def index
    
  end
  def down_zip_file
    directory = get_company_dir_path @company.id.to_s+"/excel/"
    FileUtils.mkdir_p directory unless Dir.exists?(directory)
    zipfile_name =""
    zipfile_name = (get_company_dir_path @company.id.to_s)+"/excel/export.zip"
    if File.exists?(zipfile_name)
      FileUtils.rm_f zipfile_name
    end
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      Dir[File.join(directory, '**', '**')].each do |file|
        zipfile.add(file.sub(directory, ''), file)
      end
    end
    send_file zipfile_name
  end
  def create_xsl_table
    start_time = params[:start_time]
    end_time = params[:end_time]
    #@client_infos = (Company.get_client_infos_by @company.id.to_s,start_time,end_time) || []
    @client_infs = ClientResume.
      where(["d.company_id = ? and client_resumes.created_at>=? and client_resumes.created_at <= ?",@company.id,start_time,end_time]).
      joins("left join delivery_resume_records d on client_resumes.id=d.client_resume_id").
      joins("left join positions p on d.position_id = p.id").
      select("client_resumes.id,
      client_resumes.html_content_datas,
      client_resumes.resume_template_id,
      client_resumes.has_completed,
      client_resumes.open_id,
      client_resumes.created_at,
      client_resumes.updated_at,
      p.name position_name")
    
    if @client_infs.length>0
      xls_content_for @client_infs
      render text:1
    else
      render text:2
    end
  end

  
  def xls_content_for(objs)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "form_datas"
    sheet1.row(0).concat  init_zero_line objs[-1]
    count_row = 1
    objs.each do |obj|
      sheet1.row(count_row)[0] = obj.position_name
      obj.html_content_datas.each_with_index do |a,i|
        if a[1].class == Hash
          if a[0]=="headimage"
            sheet1.row(count_row)[i+1] = Spreadsheet::Link.new "#{get_upload_file_path a[1].values[0]}",a[1].keys[0]
          elsif a[0]=~ /file/i
            sheet1.row(count_row)[i+1] = Spreadsheet::Link.new "#{get_upload_file_path a[1].values[0]}", a[1].keys[0]
          else
            sheet1[count_row, i+1]= (a[1].values[0].is_a?(Array) ? a[1].values[0].join(",") : a[1].values[0]) if a[1].values[0]
          end
        end
      end
      count_row+=1
    end
    file_path = (get_company_dir_path @company.id.to_s)+"/excel/export.xls"
    FileUtils.rm file_path if File.exists?(file_path)
    book.write file_path
  end
  def init_zero_line(obj)
    arr =["所求职位"]
    obj.html_content_datas.each do |a|
      if a[1].class == Hash
        if a[0]=="headimage"
          arr << "头像链接"
        elsif a[0]=~ /file/i
          arr << "附件"
        else
          arr << a[1].keys[0]
        end
      end
    end
    arr
  end
  def get_upload_file_path(file_path)
    file_path.split("/")[4..-1].join("/")
  end
  def get_company
    @company = Company.find_by_id(params[:company_id])
  end
  def get_title
    @title = "导出简历"
  end
end
