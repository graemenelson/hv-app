require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

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

  private

  def stub_braintree_client_token(token = '123123')
    Braintree::ClientToken.expects(:generate).returns(token)
    token
  end

  def create_signup
    Signup.create(
      access_token: 'access-token',
      instagram_id: '123',
      instagram_username: 'jillsmith'
    )
  end

end
