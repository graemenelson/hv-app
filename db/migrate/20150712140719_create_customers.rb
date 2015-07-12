class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers, id: :uuid do |t|
      t.text :access_token
      t.text :braintree_id
      t.text :instagram_id
      t.text :instagram_profile_picture
      t.text :email
      t.text :instagram_username
      t.datetime :signup_began_at
      t.text :timezone

      t.timestamps null: false
    end
  end
end
