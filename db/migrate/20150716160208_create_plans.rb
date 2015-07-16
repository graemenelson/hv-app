class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans, id: :uuid do |t|
      t.text :name
      t.text :slug
      t.integer :duration
      t.integer :amount_cents

      t.timestamps null: false
    end
    add_index :plans, :slug, unique: true
  end
end
