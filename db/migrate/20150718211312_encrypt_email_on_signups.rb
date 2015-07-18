class EncryptEmailOnSignups < ActiveRecord::Migration
  def change
    remove_column :signups, :email
    change_table :signups do |t|
      t.text :email
      t.text :email_key
      t.text :email_iv
    end
  end
end
