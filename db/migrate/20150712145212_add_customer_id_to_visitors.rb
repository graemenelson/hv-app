class AddCustomerIdToVisitors < ActiveRecord::Migration
  def change
    change_table :visitors do |t|
      t.references :customer, index: true, foreign_key: true, type: :uuid
    end
  end
end
