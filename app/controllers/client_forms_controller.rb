#encoding:utf-8
class ClientFormsController < ApplicationController
  layout:'client_form'
  def get_form_date
    p 12312312312312
    form = params[:form]
    form_hash ="{"
    form.each do |f|
      value =f[1][:value]
      if f[1][:value].class.eql?(Array)
        value = f[1][:value].join(",")
      end
      form_hash +="'#{f[1][:name]}'=>'#{value}',"
    end
    form_hash = form_hash[0...-1]+"}"
    @client = Client.find_by_open_id(params[:open_id])

    if @client
      @client.update_attributes(name:params[:username] , mobiephone:params[:phone] , html_content:form_hash )
      render text:2
    else
      Client.create(name:params[:username] , mobiephone:params[:phone] , html_content:form_hash ,types:Client::TYPES[:CONCERNED],open_id:params[:open_id])
      render text:1
    end
  end
end