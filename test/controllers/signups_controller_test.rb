require 'test_helper'

class SignupsControllerTest < ActionController::TestCase

  test '#information with signup in the information collection state' do
    signup = create_signup_in_information_state
    assert_difference signup_information_event_count do
      get :information, id: signup
    end
    assert_response :ok
    assert_template :information

    assert_select "form[action='#{update_information_signup_path(signup)}']" do
      assert_select "input[type=hidden][name='signup[timezone]']"
      assert_select "input[type=email][name='signup[email]']"
      assert_select "input[type=submit]"
    end
  end
  test '#information with invalid id must raise RecordNotFound' do
    assert_raise ActiveRecord::RecordNotFound do
      get :information, id: 'blah'
    end
  end
  test '#information with completed signup' do
    signup = create_signup(completed_at: 3.days.ago)
    assert_raise ActiveRecord::RecordNotFound do
      get :information, id: signup
    end
  end

  test '#update_information with valid email and timezone' do
    signup = create_signup_in_information_state
    assert_difference signup_update_information_event_count do
      put :update_information, id: signup, signup: { email: 'jill@smith.com', timezone: 'America/Los_Angeles' }
    end
    assert_redirected_to subscription_signup_path(signup)

    signup.reload
    assert_equal 'jill@smith.com', decrypt(signup.email)
    assert_equal 'America/Los_Angeles', signup.timezone
  end
  test '#update_information with invalid email' do
    signup = create_signup_in_information_state
    assert_difference signup_update_information_with_errors_event_count do
      put :update_information, id: signup, signup: { email: '' }
    end
    assert_response :ok
    assert_template :information
    assert_error(assigns(:signup), :email)
  end

  test '#subscription with email address/timezone and no payment method nonce' do
    signup = create_signup_in_subscription_state
    token  = stub_braintree_client_token

    get :subscription, id: signup
    assert_response :ok
    assert_template :subscription
    assert_equal token, @controller.gon.braintree_client_token
    assert assigns(:plan), 'should assign plan'

    assert_select "#plan" do
      assert_select "h2", "$18"
      assert_select "p", "6 month subscription"
      assert_select "p", "$18 billed every 6 months"
    end
    assert_select "form[action='#{update_subscription_signup_path(signup)}']" do
      assert_select "div[id=braintree-form-inputs]"
      assert_select "input[name='signup[payment_method_nonce]'][type=hidden]"
      assert_select "input[name='signup[payment_method_type]'][type=hidden]"
      assert_select "input[type=submit]"
    end
  end
  test '#subscription with completed signup' do
    signup = create_signup(completed_at: 3.days.ago)
    assert_raise ActiveRecord::RecordNotFound do
      get :subscription, id: signup
    end
  end
  test '#subscription with a signup that is not ready for capturing' do
    signup = create_signup_in_information_state
    assert_difference signup_not_capturable_event_count do
      get :subscription, id: signup
    end
    assert_redirected_to information_signup_path(signup)
  end

  test '#update_subscription with a valid payment_method_nonce' do
    signup = create_signup_in_subscription_state

    response = Hashie::Mash.new({
        success?: true,
        transaction: {
          id: 'transaction-id'
        }
      })
    stub_braintree_transaction_sale_for_signup(signup, response, 'valid-credit-card')

    BuildCustomerProfileJob.expects(:perform_later)

    assert_difference customer_session_count do
      assert_difference customer_count do
        assert_difference subscriptions_count do
          assert_difference signup_completed_event_count do
            put :update_subscription, id: signup,
                                      signup: {
                                        payment_method_nonce: 'valid-credit-card',
                                        payment_method_type: 'CreditCard' }
          end
        end
      end
    end

    signup.reload
    assert signup.completed?
    assert_equal Plan.default, signup.plan
    assert_equal 'CreditCard', signup.payment_method_type
    assert_equal 'valid-credit-card', signup.payment_method_nonce

    customer = Customer.first
    assert_nil customer.profile_created_at, 'should not have a completed profile'

    subscription = customer.subscriptions.first
    assert_equal 'transaction-id', subscription.transaction_id
    assert_redirected_to build_dashboard_path
  end
  test '#update_subscription with an invalid payment_method_nonce' do
    signup = create_signup_in_subscription_state
    token  = stub_braintree_client_token

    response = Hashie::Mash.new({
        success?: false,
        transaction: {
          status: 'processor_declined'
        }
      })
    stub_braintree_transaction_sale_for_signup(signup, response, 'invalid-credit-card')

    assert_difference signup_update_subscription_with_errors_event_count do
      put :update_subscription, id: signup,
                                signup: {payment_method_nonce: 'invalid-credit-card'}
    end
    assert_response :ok
    assert_template :subscription
    assert_error(assigns[:signup], :base)
    assert_equal token, @controller.gon.braintree_client_token
  end
  test '#update_subscription with a missing payment_method_nonce' do
    signup = create_signup_in_subscription_state
    token  = stub_braintree_client_token

    assert_difference signup_update_subscription_with_errors_event_count do
      put :update_subscription, id: signup,
                                signup: {payment_method_nonce: ''}
    end
    assert_response :ok
    assert_template :subscription
    assert_error(assigns(:signup), :payment_method_nonce)
    assert_equal token, @controller.gon.braintree_client_token
  end
  test '#update_subscription with a signup that is not ready for capturing' do
    signup = create_signup_in_information_state
    assert_difference signup_not_capturable_event_count do
      put :update_subscription, id: signup,
                                signup: {payment_method_nonce: 'nonce'}
    end
    assert_redirected_to information_signup_path(signup)
  end

  private

  def signup_information_event_count
    -> { Event.where( action: 'signup_information' ).count }
  end

  def signup_update_information_event_count
    -> { Event.where( action: 'signup_update_information' ).count }
  end

  def signup_update_information_with_errors_event_count
    -> { Event.where( action: 'signup_update_information_with_errors').count }
  end

  def signup_update_subscription_with_errors_event_count
    -> { Event.where( action: 'signup_update_subscription_with_errors').count }
  end

  def signup_not_capturable_event_count
    -> { Event.where( action: 'signup_not_capturable' ).count }
  end

  def signup_completed_event_count
    -> { Event.where( action: 'signup_completed').count }
  end

  def customer_session_count
    -> { CustomerSession.count }
  end

  def customer_count
    -> { Customer.count }
  end

  def subscriptions_count
    -> { Subscription.count }
  end

  def create_signup_in_information_state
    create_signup(email: nil, payment_method_nonce: nil, timezone: nil)
  end

  def create_signup_in_subscription_state
    create_signup(email: 'jill@smith.com', timezone: 'America/Los_Angeles', payment_method_nonce: nil)
  end

  def stub_braintree_client_token(token = '123123')
    Braintree::ClientToken.expects(:generate).returns(token)
    token
  end
end
