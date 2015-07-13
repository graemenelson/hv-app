require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  setup :clear_gon

  test '#show' do
    token  = stub_braintree_client_token
    signup = create_signup
    register_event_count = ->{ Event.where(action: :registration_new).count }

    assert_difference register_event_count do
      get :show, id: signup
    end
    assert_response :ok
    assert_equal token, Gon.braintree_client_token
  end

  test '#show with invalid id must raise RecordNotFound' do
    assert_raise ActiveRecord::RecordNotFound do
      get :show, id: 'blah'
    end
  end

  test '#update with invalid email' do
    signup = create_signup

    assert_difference registration_new_with_errors_event_count do
      put :update, id: signup, signup: {email: ''}, payment_method_nonce: 'payment-nonce'
    end
    assert_response :ok
    assert_template :show
    assert_error(assigns[:signup], :email)
    refute_error(assigns[:signup], :payment_method_nonce)
    refute @controller.gon.braintree_client_token.present?, 'should not reset braintree_client_token on Gon, since we have payment_method_nonce'
  end
  test '#update with invalid payment_method_nonce' do
    token  = stub_braintree_client_token
    signup = create_signup

    assert_difference registration_new_with_errors_event_count do
      put :update, id: signup, signup: {email: 'jill@smith.com', payment_method_nonce: ''}
    end
    assert_response :ok
    assert_template :show
    refute_error(assigns[:signup], :email)
    assert_error(assigns[:signup], :payment_method_nonce)
    assert_equal token, @controller.gon.braintree_client_token
  end
  test '#update with valid email + billing info, when BT create customer failed due to bad card' do
    token  = stub_braintree_client_token
    signup = create_signup(email: 'jill@smith.com', payment_method_nonce: 'payment-nonce')

    response = Hashie::Mash.new({
        credit_card_verification: {
          status: 'processor_declined'
        }
      })
    stub_braintree_customer_create(signup, response)

    assert_difference registration_new_with_errors_event_count do
      put :update, id: signup, signup: { email: signup.email }, payment_method_nonce: signup.payment_method_nonce
    end
    assert_response :ok
    assert_template :show
    assert_error(assigns[:signup], :base)
  end
  test '#update with valid email + billing info, when BT create customer succeeds' do
    signup = create_signup(email: 'jill@smith.com', payment_method_nonce: 'payment-nonce')

    response = Hashie::Mash.new({
        success?: true,
        customer: {}
      })
    stub_braintree_customer_create(signup, response)
    # TODO: stub build_dashboard_job.perform (or make sure we have queued a job)
    assert_difference customer_count do
      assert_difference registration_completed_event_count do
        put :update, id: signup, signup: { email: signup.email, timezone: 'Pacific Time (US & Canada)' },
                                 payment_method_nonce: signup.payment_method_nonce
      end
    end
    customer = Customer.order(created_at: :desc).first
    assert_equal customer, @controller.current_customer, 'should set current customer'
    assert_equal customer, @controller.current_visitor.customer, 'should set customer on current visitor'
    assert_equal customer, Event.where( action: 'registration_completed' ).first.customer
    assert_equal 'Pacific Time (US & Canada)', customer.timezone
    assert_redirected_to build_dashboard_path
  end

  private

  def stub_braintree_client_token(token = '123123')
    Braintree::ClientToken.expects(:generate).returns(token)
    token
  end

  def registration_new_with_errors_event_count
    -> { Event.where( action: 'registration_new_with_errors' ).count }
  end

  def customer_count
    -> { Customer.count }
  end

  def registration_completed_event_count
    -> { Event.where( action: 'registration_completed').count }
  end
end
