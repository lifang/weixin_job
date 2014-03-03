class CreateCompanyProfiles < ActiveRecord::Migration
  def change
    create_table :company_profiles do |t|
      t.integer :company_id, :null => false
      t.string :html_content
      t.timestamps
    end
  end
end
