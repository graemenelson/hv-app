class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports, id: :uuid do |t|
      t.references :customer, index: true, foreign_key: true, type: :uuid
      t.date :month
      t.integer :count

      t.timestamps null: false
    end
  end
end
