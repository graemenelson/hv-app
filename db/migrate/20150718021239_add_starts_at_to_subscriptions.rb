class AddStartsAtToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.date :start_date
    end
  end
end
