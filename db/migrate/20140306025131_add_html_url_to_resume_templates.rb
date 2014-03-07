class AddHtmlUrlToResumeTemplates < ActiveRecord::Migration
  def change
    add_column :resume_templates, :html_url, :string

  end
end
