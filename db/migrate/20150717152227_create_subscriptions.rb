class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :customer, index: true, foreign_key: true, type: :uuid
      t.references :plan, index: true, foreign_key: true, type: :uuid
      t.text :transaction_id
      t.date :end_date

      t.timestamps null: false
    end
  end
end
