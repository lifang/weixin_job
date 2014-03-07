class CreateClientHtmlInfos < ActiveRecord::Migration
  def change
    create_table :client_html_infos do |t|
      t.integer :client_id
      t.text :hash_content

      t.timestamps
    end
  end
end
