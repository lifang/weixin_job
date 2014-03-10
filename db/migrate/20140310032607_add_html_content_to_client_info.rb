class AddHtmlContentToClientInfo < ActiveRecord::Migration
  def change
    add_column :client_html_infos, :html_content, :text
    add_column :tags, :company_id, :integer
  end
end
