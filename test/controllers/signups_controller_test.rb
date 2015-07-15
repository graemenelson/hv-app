require 'test_helper'

class SignupsControllerTest < ActionController::TestCase

  test '#information with signup in the information collection state' do
    signup = create_signup_in_information_state
    assert_difference signup_information_event_count do
      get :information, id: signup
    end
    assert_response :ok
    assert_template :information
  end
  test '#information with invalid id must raise RecordNotFound' do
    assert_raise ActiveRecord::RecordNotFound do
      get :information, id: 'blah'
    end
  end

  test '#update_information with valid email' do
    signup = create_signup_in_information_state
    assert_difference signup_update_information_event_count do
      put :update_information, id: signup, signup: { email: 'jill@smith.com' }
    end
    assert_redirected_to subscription_signup_path(signup)
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

  def create_signup_in_information_state
    create_signup(email: nil, payment_method_nonce: nil)
  end
end
