class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :customer, index: true, foreign_key: true, type: :uuid
      t.references :plan, index: true, foreign_key: true, type: :uuid
      t.text :transaction_id
      t.datetime :ends_at

      t.timestamps null: false
    end
  end
end
