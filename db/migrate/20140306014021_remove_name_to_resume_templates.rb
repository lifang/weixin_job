class RemoveNameToResumeTemplates < ActiveRecord::Migration
  def change
    remove_column :resume_templates, :name
  end
end
