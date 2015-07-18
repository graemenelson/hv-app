class AddProfileCreatedAtToCustomers < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.datetime :profile_created_at
    end
  end
end
