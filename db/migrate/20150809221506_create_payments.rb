class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments, id: :uuid do |t|
      t.string :transaction_id
      t.references :customer, index: true, foreign_key: true, type: :uuid
      t.integer :amount_cents
      t.timestamps null: false
    end
  end
end
