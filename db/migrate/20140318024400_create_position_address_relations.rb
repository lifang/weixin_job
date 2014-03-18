class CreatePositionAddressRelations < ActiveRecord::Migration
  def change
    create_table :position_address_relations do |t|
      t.integer :position_id, :null => false
      t.integer :work_address_id, :null => false
      t.integer :company_id, :null => false
      t.timestamps
    end
  end

end
