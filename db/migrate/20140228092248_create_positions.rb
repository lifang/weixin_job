#encoding: utf-8
class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :name
      t.integer :status #状态(正常,删除)
      t.string :requirement #(要求)
      t.string :description #(描述)
      t.integer :position_type_id, :null => false
      t.timestamps
    end
  end
end
