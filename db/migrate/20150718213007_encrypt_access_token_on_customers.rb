class EncryptAccessTokenOnCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :access_token
    change_table :customers do |t|
      t.text :access_token
      t.text :access_token_key
      t.text :access_token_iv
    end
  end
end
