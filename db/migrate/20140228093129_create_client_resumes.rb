#encoding: utf-8
class CreateClientResumes < ActiveRecord::Migration
  def change
    create_table :client_resumes do |t|
      t.string :html_content_datas
      t.integer :resume_template_id, :null => false
      t.boolean :has_completed, :default => true  #简历是否填写完整
      t.string :open_id
      t.timestamps
    end
  end
end
