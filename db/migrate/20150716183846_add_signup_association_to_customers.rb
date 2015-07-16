class AddSignupAssociationToCustomers < ActiveRecord::Migration
  def change
    change_table :customers do |t|
      t.references :signup, index: true, type: :uuid
    end
  end
end
