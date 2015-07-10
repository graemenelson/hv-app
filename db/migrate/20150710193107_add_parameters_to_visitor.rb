class AddParametersToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :parameters, :hstore, default: {}, null: false
  end
end
