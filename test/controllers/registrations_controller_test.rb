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
    assert_difference registration_completed_event_count do
      put :update, id: signup, signup: {email: 'jill@smith.com'}
    end

    assert_redirected_to payment_path
  end

  private

  def registration_new_with_errors_event_count
    -> { Event.where( action: 'registration_new_with_errors' ).count }
  end

  def registration_completed_event_count
    -> { Event.where( action: 'registration_completed').count }
  end

end
