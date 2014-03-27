class CreateWorkAddresses < ActiveRecord::Migration
  def change
    create_table :work_addresses do |t|
      t.string :address
      t.integer :city_id, :null => false
      t.integer :company_id, :null => false
      t.timestamps
    end
  end

end
