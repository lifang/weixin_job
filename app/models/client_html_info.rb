#encoding: utf-8
class ClientHtmlInfo < ActiveRecord::Base
  attr_accessible :client_id, :hash_content,  :html_content
  belongs_to :client

  serialize :hash_content
end
