class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :root_path
      t.integer :status, :default => 1
      t.string :cweb
      t.boolean :has_app, :default => false
      t.string :app_account
      t.string :app_password
      t.timestamps
    end
  end
end
