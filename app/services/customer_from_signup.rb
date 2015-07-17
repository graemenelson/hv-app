class CustomerFromSignup

  include StrongParametersMixin

  attr_reader :signup,
              :customer,
              :error

  delegate :instagram_id,
           :instagram_username,
           :email,
           :payment_method_nonce,
           :plan,
           to: :signup

  delegate :amount,
           to: :plan

  SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER = [
    :instagram_id,
    :instagram_username,
    :instagram_profile_picture,
    :access_token,
    :email,
    :timezone
  ]
  PERMITTED_CUSTOMER_ATTRIBUTES = SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER + [
    :signup_began_at,
    :braintree_id
  ]

  def self.call(signup)
    self.new(signup).call
  end

  def initialize(signup)
    @signup = signup
  end

  def call
    response = create_braintree_transaction
    if response.success?
      self.customer = Customer.create!(attributes_for_consumer_from_signup.merge(signup: signup))
      create_customer_subscription(response.transaction)
      signup.completed!
    else
      response.errors.present? ?
        record_response_errors(response.errors) :
        record_transaction_error(response.transaction)
    end

    self
  end

  private

  attr_writer :error,
              :customer

  def attributes_for_consumer_from_signup
    signup_attributes   = Hashie::Mash.new(signup.attributes)
    customer_attributes = signup_attributes.slice(*SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER)
    customer_attributes.merge!(signup_began_at: signup.created_at, braintree_id: instagram_id)
    strong_parameters(customer_attributes).permit(*PERMITTED_CUSTOMER_ATTRIBUTES)
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
    response.errors.each do |error|
      messages << "#{error.code} - #{error.message}"
    end

    fail "Braintree Error [#{messages.join(', ')}] for Signup (#{signup.id})"
  end

  def create_customer_subscription(transaction)
    customer.subscriptions.create({
        transaction_id: transaction.id,
        plan: plan,
        ends_at: subscription_ends_at_from_plan
      })
  end

  def subscription_ends_at_from_plan
    current_timezone = Time.zone
    Time.zone = customer.timezone || current_timezone

    end_month = plan.duration.month.from_now
    ends_at   = end_month.beginning_of_month

    Time.zone = current_timezone
    ends_at
  end

end
