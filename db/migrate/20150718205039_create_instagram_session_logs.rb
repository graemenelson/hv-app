class CreateInstagramSessionLogs < ActiveRecord::Migration
  def change
    create_table :instagram_session_logs, id: :uuid do |t|
      t.references :instagram_session, index: true, type: :uuid, foreign_key: true
      t.integer    :response_time
      t.string     :endpoint
      t.text       :params
      t.integer    :status

      t.datetime :created_at
    end
  end
end
