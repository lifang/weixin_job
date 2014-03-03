class CreateResumeTemplates < ActiveRecord::Migration
  def change
    create_table :resume_templates do |t|
      t.string :html_content
      t.integer :company_id, :null => false
      t.timestamps
    end
  end
end
