require 'test_helper'

class CustomerFromSignupTest < ActiveSupport::TestCase
  test '#call when customer is created' do
    signup   = create_signup(email: 'jill@smith.com',
                             timezone: 'Pacific Time (US & Canada)',
                             instagram_profile_picture: 'http://path/to/profile-picture.png')

    customer = CustomerFromSignup.call(signup).customer
    assert customer
    assert_equal signup.access_token, customer.access_token
    assert_equal signup.instagram_id, customer.instagram_id
    assert_equal signup.instagram_username, customer.instagram_username
    assert_equal signup.email, customer.email
    assert_equal signup.created_at, customer.signup_began_at
    assert_equal signup.instagram_profile_picture, customer.instagram_profile_picture
    assert_equal signup.timezone, customer.timezone

    assert signup.destroyed?
  end
  
end
