class AddNameToResumeTemplates < ActiveRecord::Migration
  def change
    add_column :resume_templates, :name, :string, :null => false

  end
end
