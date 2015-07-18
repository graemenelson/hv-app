class EncryptEmailOnCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :email
    change_table :customers do |t|
      t.text :email
      t.text :email_key
      t.text :email_iv
    end
  end
end
