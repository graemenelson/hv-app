class CreateCustomerSessions < ActiveRecord::Migration
  def change
    create_table :customer_sessions, id: :uuid do |t|
      t.references :customer, type: :uuid
      t.references :visitor, type: :uuid
      t.datetime :last_accessed_at
      t.timestamps null: false
    end
  end
end
