require 'test_helper'

class CustomerFromSignupTest < ActiveSupport::TestCase
  test '#call when BT transaction fails on customer creation' do
    signup = create_signup_with_plan
    response = Hashie::Mash.new({
        success?: false,
        errors: [],
        transaction: {
          status: 'processor_declined'
        }
      })

    stub_braintree_transaction_sale(signup, response)

    service = CustomerFromSignup.call(signup)
    refute service.customer.present?
    assert_equal response.transaction.status, service.error
  end
  test '#call when braintree customer creation is successful' do
    signup   = create_signup_with_plan(email: 'jill@smith.com',
                             timezone: 'Pacific Time (US & Canada)',
                             instagram_profile_picture: 'http://path/to/profile-picture.png')
    response = Hashie::Mash.new({
        success?: true,
        transaction: {
          id: 'transaction-id'
        }
      })

    stub_braintree_transaction_sale(signup, response)

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
    assert_equal signup, customer.signup

    subscription = customer.subscriptions.first
    assert_equal 'transaction-id', subscription.transaction_id
    assert_equal signup.plan, subscription.plan
    expected_starts_at = 1.month.ago.beginning_of_month
    assert_equal expected_starts_at.to_s, subscription.starts_at.to_s
    expected_ends_at   = 4.months.from_now.end_of_month
    assert_equal expected_ends_at.to_s, subscription.ends_at.to_s

    assert signup.completed?, "signup should now be completed"
  end

  private

  def create_signup_with_plan(attrs = {})
    create_signup(attrs.merge(plan: Plan.default))
  end

end
