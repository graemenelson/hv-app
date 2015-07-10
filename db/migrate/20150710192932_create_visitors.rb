class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors, id: :uuid do |t|
      t.text :ip
      t.text :referrer
      t.text :path
      t.text :user_agent
      t.hstore :parameters, default: {}, null: false

      t.datetime :created_at, null: false
    end
    add_index :visitors, :parameters, using: :gin
  end
end
