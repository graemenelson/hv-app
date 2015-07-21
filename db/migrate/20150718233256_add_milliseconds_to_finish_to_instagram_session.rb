class AddMillisecondsToFinishToInstagramSession < ActiveRecord::Migration
  def change
    change_table :instagram_sessions do |t|
      t.integer :milliseconds_to_finish
    end
  end
end
