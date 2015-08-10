require 'test_helper'

class CreatePaymentTest < ActiveSupport::TestCase
  test '#call with no attributes' do
    service = CreatePayment.call({})
    refute service.valid?
    refute service.payment
    assert_error(service, :customer)
    assert_error(service, :amount)
  end
  test "#call with valid attributes and a valid payment method" do
    customer = create_customer(braintree_id: '12345')
    customer_response = Hashie::Mash.new(
      payment_methods: [
        Hashie::Mash.new(expired?: false, token: 'payment-token')
      ]
    )
    stub_brainree_customer_find(customer.braintree_id, customer_response)
    stub_braintree_transaction_sale({
      payment_method_token: 'payment-token',
      amount: '3.00',
      options: {submit_for_settlement: true}
      }, Hashie::Mash.new( success?: true,
                           transaction: { id: 'transaction-id'}) )

    service  = CreatePayment.call(customer: customer, amount: "3.00")
    payment  = service.payment
    assert_equal 300, payment.amount_cents
    assert_equal 'transaction-id', payment.transaction_id
    assert_equal customer, payment.customer
  end
end
