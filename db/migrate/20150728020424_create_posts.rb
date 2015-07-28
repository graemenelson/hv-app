class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, id: :uuid do |t|
      t.references :report, index: true, type: :uuid, foreign_key: true
      t.text :media_id
      t.integer :likes_count
      t.integer :comments_count
      t.text :caption
      t.string :media_type
      t.text :media_url
      t.text :url
      t.timestamps null: false
    end
  end
end
