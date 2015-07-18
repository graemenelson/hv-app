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
      has_response_errors?(response) ?
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

  def create_customer_subscription(transaction)
    customer.subscriptions.create({
        transaction_id: transaction.id,
        plan: plan,
        starts_at: subscription_starts_at_from_plan,
        ends_at: subscription_ends_at_from_plan
      })
  end

  def subscription_starts_at_from_plan
    with_customer_timezone do
      1.month.ago.beginning_of_month
    end
  end

  def subscription_ends_at_from_plan
    with_customer_timezone do
      # TODO: improve readability of the ends_at calculation for subsscription
      #       -- you go one month back and take the plan duration minus 1
      (1.month.ago + (plan.duration-1).months).end_of_month
    end
  end

  def with_customer_timezone(&block)
    current_timezone = Time.zone
    Time.zone = customer.timezone || current_timezone
    result = yield
    Time.zone = current_timezone
    result
  end

end
