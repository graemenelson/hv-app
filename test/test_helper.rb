ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'hashie'

class ActionController::TestCase
  def signin_customer(customer)
    customer_session = CustomerSession.create(customer: customer)
    session[:customer_session_id] = customer_session.id
    customer_session
  end
end

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

  def decrypt(value)
    value.is_a?( Strongbox::Lock ) ?
      value.decrypt(ENV['STRONGBOX_PASSWORD']) :
      value
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

  def stub_create_report_job(report)
    CreateReportJob.expects(:perform_later).with(report)
  end  

  def assert_error(signup, key, message = nil)
    assert signup.errors[key].present?, message || "expected error on '#{key}'"
  end
  def refute_error(signup, key, message = nil)
    refute signup.errors[key].present?, message || "unexpected error on '#{key}'"
  end

  def with_timezone(timezone, &block)
    current_timezone = Time.zone
    Time.zone = timezone || current_timezone
    yield
    Time.zone = current_timezone
  end

  def stub_braintree_customer_create(signup, response, payment_method_nonce = nil)
    Braintree::Customer.expects(:create)
                       .with(expected_attributes_to_braintree_customer_create(signup, payment_method_nonce))
                       .returns(response)
  end

  def stub_brainree_customer_find(braintree_id, response)
    Braintree::Customer.expects(:find)
                       .with(braintree_id)
                       .returns(response)
  end

  def stub_braintree_transaction_sale(attrs, response)
    Braintree::Transaction.expects(:sale)
                          .with(attrs)
                          .returns(response)
  end

  def stub_braintree_transaction_sale_for_signup(signup, response, payment_method_nonce = nil)
    stub_braintree_transaction_sale(expected_attributes_to_braintree_transaction_sale(signup, payment_method_nonce),
                                    response)
  end

  def expected_attributes_to_braintree_customer_create(signup, payment_method_nonce = nil)
    {
      id: signup.instagram_id,
      payment_method_nonce: payment_method_nonce || signup.payment_method_nonce,
      email: decrypt(signup.email),
      website: "http://instagram.com/#{signup.instagram_username}"
    }
  end

  def expected_attributes_to_braintree_transaction_sale(signup, payment_method_nonce = nil)
    {
      amount: (signup.plan || Plan.default).amount,
      payment_method_nonce: payment_method_nonce || signup.payment_method_nonce,
      options: {
        submit_for_settlement: true,
        store_in_vault_on_success: true
      },
      customer: {
        id: signup.instagram_id,
        email: decrypt(signup.email),
        website: "https://instagram.com/#{signup.instagram_username}"
      }
    }
  end

  def stub_instagram_session_user_media(job, results = [])
    session = mock('instagram-session')
    job.expects(:instagram_session).at_least_once.returns(session)
    session.expects(:user_media).returns(results)
    session.expects(:close!)
  end

end
