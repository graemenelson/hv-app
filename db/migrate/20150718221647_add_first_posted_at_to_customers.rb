class AddFirstPostedAtToCustomers < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.datetime :first_posted_at
    end
  end
end
