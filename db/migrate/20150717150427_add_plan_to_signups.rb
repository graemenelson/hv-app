class AddPlanToSignups < ActiveRecord::Migration
  def change
    change_table :signups do |t|
      t.references :plan, index: true, type: :uuid
    end
  end
end
