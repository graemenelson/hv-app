class CustomerFromSignup

  include StrongParametersMixin

  attr_reader :signup,
              :customer,
              :error

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
    @error = "this is just a placeholder"
    response = Braintree::Customer.create({
        id: instagram_id,
        payment_method_nonce: payment_method_nonce,
        email: email,
        website: "http://instagram.com/#{instagram_username}"
      })

    if response.success?
      @customer = Customer.create!(attributes_for_consumer_from_signup.merge(signup: signup))
      signup.completed!
    else
      if response.credit_card_verification
        @error = response.credit_card_verification
      else
        errors = []
        response.errors.each do |error|
          errors << "#{error.code} - #{error.message}"
        end
        # TODO: we might want to handle certain Braintree errors, like customer id already taken
        #       -- for now, we are keeping things crude and just blowing up, since we might never hit
        #          that exception
        fail "Braintree Error [#{errors.join(', ')}] for Signup (#{signup.id})"
      end
    end

    self
  end

  private

  def attributes_for_consumer_from_signup
    signup_attributes   = Hashie::Mash.new(signup.attributes)
    customer_attributes = signup_attributes.slice(*SIGNUP_ATTRIBUTES_TO_MOVE_TO_CUSTOMER)
    customer_attributes.merge!(signup_began_at: signup.created_at, braintree_id: instagram_id)
    strong_parameters(customer_attributes).permit(*PERMITTED_CUSTOMER_ATTRIBUTES)
  end

end
