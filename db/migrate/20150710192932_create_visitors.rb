class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors, id: :uuid do |t|
      t.text :ip
      t.text :referrer
      t.text :path
      t.text :user_agent

      t.timestamps null: false
    end
  end
end
