class AddMoreInstagramAttributesToCustomers < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.text :instagram_full_name
      t.text :website
      t.integer :instagram_follows_count
      t.integer :instagram_followed_by_count
      t.integer :instagram_media_count
    end
  end
end
