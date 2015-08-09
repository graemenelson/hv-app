class AddPurchaseableToReports < ActiveRecord::Migration
  def change
    change_table :reports do |t|
      t.string :purchaseable_type
      t.uuid   :purchaseable_id
    end
  end
end
