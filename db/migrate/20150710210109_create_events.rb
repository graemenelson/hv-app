class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events, id: :uuid do |t|
      t.references :visitor, index: true, type: :uuid
      t.text :action
      t.text :app_version
      t.text :ip
      t.text :referrer
      t.text :path
      t.text :user_agent
      t.hstore :parameters, default: {}, null: false

      t.datetime :created_at, null: false
    end

    add_foreign_key :events, :visitors
    add_index :events, :parameters, using: :gin
  end
end
