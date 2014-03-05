class ChangeHtmlContentToResumeTemplates < ActiveRecord::Migration
 def change
   change_column :resume_templates, :html_content, :text
   change_column :client_resumes, :html_content_datas, :text
   change_column :company_profiles, :html_content, :text
 end
end
