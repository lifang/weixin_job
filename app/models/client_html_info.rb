class ClientHtmlInfo < ActiveRecord::Base
  attr_accessible :client_id, :hash_content,  :html_content
  serialize :hash_content
  belongs_to :client
end
