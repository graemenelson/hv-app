require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  test '#show' do
    signup = Signup.create
    register_event_count = ->{ Event.where(action: :register).count }

    assert_difference register_event_count do
      get :show, id: signup
    end
    assert_response :ok
  end
end
