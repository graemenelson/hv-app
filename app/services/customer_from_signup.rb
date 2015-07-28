# Creates a new customer from a Braintree Transaction sale.
# If the customer was created, then we also create a new
# subscription for the customer based on the plan.
class CustomerFromSignup < BaseService

  include StrongParametersMixin
  include StrongboxMixin

  attr_reader :signup,
              :customer,
              :error

  delegate :instagram_id,
           :instagram_username,
           :payment_method_nonce,
           :plan,
           to: :signup

  delegate :amount,
           to: :plan

  SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER = [
    :instagram_id,
    :instagram_username,
    :instagram_profile_picture,
    :timezone
  ]
  PERMITTED_CUSTOMER_ATTRIBUTES = SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER + [
    :signup_began_at,
    :braintree_id,
    :access_token,
    :email
  ]

  def initialize(signup)
    @signup = signup
  end

  def perform
    response = create_braintree_transaction
    if response.success?
      self.customer = Customer.create!(attributes_for_consumer_from_signup.merge(signup: signup))
      CreateSubscription.call( customer: customer,
                               transaction_id: response.transaction.id,
                               plan: plan,
                               start_date: 1.month.ago)
      signup.completed!
    else
      has_response_errors?(response) ?
        record_response_errors(response.errors) :
        record_transaction_error(response.transaction)
    end
  end

  private

  attr_writer :error,
              :customer

  def attributes_for_consumer_from_signup
    signup_attributes   = Hashie::Mash.new(signup.attributes)
    customer_attributes = signup_attributes.slice(*SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER)
    customer_attributes.merge!(signup_began_at: signup.created_at,
                               braintree_id: instagram_id,
                               access_token: access_token,
                               email:        email)
    strong_parameters(customer_attributes).permit(*PERMITTED_CUSTOMER_ATTRIBUTES)
  end

  def has_response_errors?(response)
    return false unless response.errors && response.errors.size > 0
  end

  def create_braintree_transaction
    Braintree::Transaction.sale({
      amount: amount,
      payment_method_nonce: payment_method_nonce,
      options: {
        submit_for_settlement: true,
        store_in_vault_on_success: true
      },
      customer: {
        id: instagram_id,
        email: email,
        website: "https://instagram.com/#{instagram_username}"
      }
    })
  end

  def record_transaction_error(transaction)
    self.error = transaction.status
  end

  # NOTE: not handling response errors from BT when creating
  # a transaction.
  def record_response_errors(errors)
    messages = []
    errors.each do |error|
      messages << "#{error.code} - #{error.message}"
    end

    fail "Braintree Error [#{messages.join(', ')}] for Signup (#{signup.id})"
  end

  def email
    decrypt(signup.email)
  end

  def access_token
    decrypt(signup.access_token)
  end

end
