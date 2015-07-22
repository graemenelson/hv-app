class AddNameToInstagramSessions < ActiveRecord::Migration
  def change
    change_table :instagram_sessions do |t|
      t.text :name
    end
  end
end
