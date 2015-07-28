class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: :uuid do |t|
      t.references :post, index: true, type: :uuid, foreign_key: true
      t.text :text
      t.string :username
      t.text :profile_picture
      t.datetime :created_at
    end
  end
end
