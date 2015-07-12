require 'test_helper'

class CustomerFromSignupTest < ActiveSupport::TestCase
  test '#call when credit card validation fails on customer creation' do
    signup = create_signup
    response = Hashie::Mash.new({
        credit_card_verification: {
          status: 'processor_declined'
        }
      })

    stub_braintree_customer_create(signup, response)

    service = CustomerFromSignup.call(signup)
    refute service.customer.present?
    assert_equal response.credit_card_verification, service.error
  end
  test '#call when braintree customer creation is successful' do
    signup   = create_signup(email: 'jill@smith.com',
                             timezone: 'Pacific Time (US & Canada)',
                             instagram_profile_picture: 'http://path/to/profile-picture.png')
    response = Hashie::Mash.new({
        success?: true,
        customer: {}
      })

    stub_braintree_customer_create(signup, response)

    customer = CustomerFromSignup.call(signup).customer
    assert customer
    assert_equal signup.access_token, customer.access_token
    assert_equal signup.instagram_id, customer.instagram_id
    assert_equal signup.instagram_username, customer.instagram_username
    assert_equal signup.email, customer.email
    assert_equal signup.created_at, customer.signup_began_at
    assert_equal signup.instagram_id, customer.braintree_id
    assert_equal signup.instagram_profile_picture, customer.instagram_profile_picture
    assert_equal signup.timezone, customer.timezone

    assert signup.destroyed?
  end

  private

  def stub_braintree_customer_create(signup, response)
    Braintree::Customer.expects(:create)
                       .with(expected_attributes_to_braintree_customer_create(signup))
                       .returns(response)
  end

  def expected_attributes_to_braintree_customer_create(signup)
    {
      id: signup.instagram_id,
      payment_method_nonce: signup.payment_method_nonce,
      email: signup.email,
      website: "http://instagram.com/#{signup.instagram_username}"
    }
  end
end
