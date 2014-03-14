class CreateExportRecords < ActiveRecord::Migration
  def change
    create_table :export_records do |t|
      t.datetime :begin_time
      t.datetime :end_time
      t.integer :company_id

      t.timestamps
    end
  end
end
