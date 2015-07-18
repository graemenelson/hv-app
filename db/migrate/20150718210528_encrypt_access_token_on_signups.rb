class EncryptAccessTokenOnSignups < ActiveRecord::Migration
  def change
    remove_column :signups, :access_token
    change_table :signups do |t|
      t.text :access_token
      t.text :access_token_key
      t.text :access_token_iv      
    end
  end
end
