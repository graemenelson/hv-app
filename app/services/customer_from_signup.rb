class CustomerFromSignup

  include StrongParametersMixin

  attr_reader :signup,
              :customer

  delegate :instagram_id,
           :instagram_username,
           :email,
           :payment_method_nonce,
           to: :signup

  SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER = [
    :instagram_id,
    :instagram_username,
    :instagram_profile_picture,
    :access_token,
    :email,
    :timezone
  ]
  PERMITTED_CUSTOMER_ATTRIBUTES = SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER + [
    :signup_began_at
  ]

  def self.call(signup)
    self.new(signup).call
  end

  def initialize(signup)
    @signup = signup
  end

  def call
    @customer = Customer.create!(attributes_for_consumer_from_signup)
    signup.destroy
    self
  end

  private

  def attributes_for_consumer_from_signup
    signup_attributes   = Hashie::Mash.new(signup.attributes)
    customer_attributes = signup_attributes.slice(*SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER)
    customer_attributes.merge!(signup_began_at: signup.created_at)
    strong_parameters(customer_attributes).permit(*PERMITTED_CUSTOMER_ATTRIBUTES)
  end

end
