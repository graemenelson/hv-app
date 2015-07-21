class AddInstagramTimestampsToReports < ActiveRecord::Migration
  def change
    change_table :reports do |t|
      t.integer :min_timestamp
      t.integer :max_timestamp
    end
  end
end
