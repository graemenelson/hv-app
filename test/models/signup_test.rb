require 'test_helper'

class SignupTest < ActiveSupport::TestCase
  test 'basic validations' do
    signup = Signup.new
    refute signup.valid?
    assert_error(signup, :access_token)
    assert_error(signup, :instagram_id)
    assert_error(signup, :instagram_username)
    refute_error(signup, :email)
  end
  test 'update validations' do
    signup = create_signup(email: nil)
    refute signup.update_attributes(email: '')
    assert_error(signup, :email)
  end
  test 'update validations with allow_blank_email and no email' do
    signup = create_signup(email: nil, payment_method_nonce: 'my-nonce')
    token  = 'new-access-token'
    assert signup.update_attributes( access_token: token, allow_blank_email: true )
    assert_equal token, signup.access_token
  end
  test 'update validations with allow_blank_payment_method_nonce and no payment_method_nonce' do
    signup = create_signup(email: 'jill@smith.com')
    token  = 'new-access-token'
    assert signup.update_attributes( access_token: token, allow_blank_payment_method_nonce: true )
    assert_equal token, signup.access_token
  end
end
