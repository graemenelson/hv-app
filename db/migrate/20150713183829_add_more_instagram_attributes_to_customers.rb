class AddMoreInstagramAttributesToCustomers < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.text :instagram_full_name
      t.text :website
      t.integer :instagram_follows
      t.integer :instagram_followed_by
    end
  end
end
