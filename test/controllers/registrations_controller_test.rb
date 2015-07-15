require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  setup :clear_gon

  test '#show' do
    signup = create_signup
    register_event_count = ->{ Event.where(action: :registration_new).count }

    assert_difference register_event_count do
      get :show, id: signup
    end
    assert_response :ok
  end

  test '#show with invalid id must raise RecordNotFound' do
    assert_raise ActiveRecord::RecordNotFound do
      get :show, id: 'blah'
    end
  end

  test '#update with invalid email' do
    signup = create_signup
    assert_difference registration_new_with_errors_event_count do
      put :update, id: signup, signup: {email: ''}
    end
    assert_response :ok
    assert_template :show
    assert_error(assigns[:signup], :email)
  end
  test '#update with valid email' do
    signup = create_signup
    assert_difference customer_count do
      assert_difference registration_completed_event_count do
        put :update, id: signup, signup: {email: 'jill@smith.com', timezone: 'America/Los_Angeles'}
      end
    end

    customer = Customer.first
    assert_equal 'America/Los_Angeles', customer.timezone
    assert_redirected_to payment_path
  end

  private

  def customer_count
    -> { Customer.count }
  end

  def registration_new_with_errors_event_count
    -> { Event.where( action: 'registration_new_with_errors' ).count }
  end

  def registration_completed_event_count
    -> { Event.where( action: 'registration_completed').count }
  end

end
