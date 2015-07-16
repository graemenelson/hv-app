class AddCompletedAtToSignups < ActiveRecord::Migration
  def change
    change_table :signups do |t|
      t.datetime :completed_at
    end
  end
end
