class CreatePayment < BaseService

  attr_reader :customer,
              :amount,
              :payment

  validates :customer, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def initialize(attrs = {})
    @customer = attrs[:customer]
    @amount   = attrs[:amount]
  end

  def perform
    load_braintree_customer
    load_payment_method
    create_sale
    create_payment
  end

  private

  attr_reader :braintree_customer,
              :payment_method,
              :sale

  def load_braintree_customer
    @braintree_customer = Braintree::Customer.find(customer.braintree_id)
  end

  def load_payment_method
    return unless braintree_customer
    @payment_method = braintree_customer.payment_methods.find {|pm| !pm.expired? }
  end

  def create_sale
    return unless payment_method
    @sale = Braintree::Transaction.sale(payment_method_token: payment_method.token,
                                               amount: amount,
                                               options: {
                                                 submit_for_settlement: true
                                                 })
  end

  def create_payment
    return unless sale && sale.success?
    @payment = customer.payments.create( transaction_id: sale.transaction.id, amount_cents: amount_in_cents )
  end

  def amount_in_cents
    amount.to_f * 100
  end

end
