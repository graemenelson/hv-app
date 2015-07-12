require 'test_helper'

class SignupTest < ActiveSupport::TestCase
  test 'basic validations' do
    signup = Signup.new
    refute signup.valid?
    assert_error(signup, :access_token)
    assert_error(signup, :instagram_id)
    assert_error(signup, :instagram_username)
    refute_error(signup, :email)
    refute_error(signup, :payment_method_nonce)
  end
  test '#captured_email_and_billing_info? with email and billing info captured' do
    signup = create_signup({email: 'jill@smith.com', payment_method_nonce: 'nonce'})
    assert signup.captured_email_and_billing_info?
  end
  test '#captured_email_and_billing_info? with missing email and billing info' do
    signup = create_signup
    refute signup.captured_email_and_billing_info?
    assert_error(signup, :email)
    assert_error(signup, :payment_method_nonce)
  end

end
