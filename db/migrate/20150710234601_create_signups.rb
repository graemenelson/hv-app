class CreateSignups < ActiveRecord::Migration
  def change
    create_table :signups, id: :uuid do |t|
      t.text :instagram_id
      t.text :instagram_username
      t.text :email
      t.text :access_token

      t.timestamps null: false
    end
    add_index :signups, :instagram_id
  end
end
