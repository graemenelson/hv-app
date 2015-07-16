ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'hashie'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # setup helper method to clear Gon, not required for all
  # tests -- so do use you must specify in your test:
  #
  #     setup :clear_gon
  def clear_gon
    Gon.clear
  end

  # Add more helper methods to be used by all tests here...
  def create_signup(attrs = {})
    Signup.create!(attrs.reverse_merge({
        access_token: 'access-token',
        instagram_username: 'jillsmith',
        instagram_id: '123456'
      }))
  end

  def create_customer(attrs = {})
    Customer.create!(attrs.reverse_merge({
        email: 'jill@smith.com',
        access_token: 'access-token',
        instagram_username: 'jillsmith',
        instagram_id: '123456',
        braintree_id: '123456',
        timezone: 'Pacific Time (US & Canada)'
      }))
  end

  def create_plan(attrs = {})
    Plan.create!(attrs.reverse_merge({
        name: "$18 for 6 months",
        slug: 'six-month-plan',
        duration: 6,
        amount_cents: 1800
      }))
  end

  def assert_error(signup, key, message = nil)
    assert signup.errors[key].present?, message || "expected error on '#{key}'"
  end
  def refute_error(signup, key, message = nil)
    refute signup.errors[key].present?, message || "unexpected error on '#{key}'"
  end

  def stub_braintree_customer_create(signup, response, payment_method_nonce = nil)
    Braintree::Customer.expects(:create)
                       .with(expected_attributes_to_braintree_customer_create(signup, payment_method_nonce))
                       .returns(response)
  end

  def expected_attributes_to_braintree_customer_create(signup, payment_method_nonce = nil)
    {
      id: signup.instagram_id,
      payment_method_nonce: payment_method_nonce || signup.payment_method_nonce,
      email: signup.email,
      website: "http://instagram.com/#{signup.instagram_username}"
    }
  end

end
