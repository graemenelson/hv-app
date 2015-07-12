class AddPaymentMethodNonceToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :payment_method_nonce, :text
  end
end
