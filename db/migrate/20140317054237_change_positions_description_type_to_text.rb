class ChangePositionsDescriptionTypeToText < ActiveRecord::Migration
  def change
    change_column :positions, :description, :text
  end
end
