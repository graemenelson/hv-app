class CreateInstagramSessions < ActiveRecord::Migration
  def change
    create_table :instagram_sessions, id: :uuid do |t|
      t.text :access_token
      t.text :access_token_key
      t.text :access_token_iv
      t.datetime :finished_at
      t.datetime :created_at
      t.string   :error
      t.text     :backtrace
    end
  end
end
