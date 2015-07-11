class CreateSignups < ActiveRecord::Migration
  def change
    create_table :signups, id: :uuid do |t|
      t.text :instagram_id
      t.text :instagram_username
      t.text :instagram_profile_picture
      t.text :email
      t.text :access_token
      t.text :timezone

      t.timestamps null: false
    end
    add_index :signups, :instagram_id
  end
end
