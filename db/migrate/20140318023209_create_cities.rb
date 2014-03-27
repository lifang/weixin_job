class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.integer :order_index
      t.string :name
      t.integer :parent_id
      t.timestamps
    end
  end
end
