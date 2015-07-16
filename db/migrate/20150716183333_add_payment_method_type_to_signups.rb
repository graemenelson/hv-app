class AddPaymentMethodTypeToSignups < ActiveRecord::Migration
  def change
    change_table :signups do |t|
      t.text :payment_method_type
    end
  end
end
