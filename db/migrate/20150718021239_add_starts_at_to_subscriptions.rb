class AddStartsAtToSubscriptions < ActiveRecord::Migration
  def change
    change_table :subscriptions do |t|
      t.datetime :starts_at
    end
  end
end
