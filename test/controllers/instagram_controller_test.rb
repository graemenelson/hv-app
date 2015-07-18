require 'test_helper'

class InstagramControllerTest < ActionController::TestCase
  tests InstagramController

  test '#connect must redirect to instagram authorization endpoint' do
    instagram_callback = auth_instagram_callback_url
    instagram_endpoint = "https://api.instagram.com/oauth/authorize/?client_id=#{Instagram.client_id}&redirect_uri=#{CGI::escape(instagram_callback)}&response_type=code"
    connect_event_count = -> { Event.where(action: :connect).count}

    assert_difference connect_event_count do
      get :connect
    end
    assert_equal instagram_endpoint, response.location
  end

  test '#callback with no account or signup associated with instagram_id' do
    code     = '123123123'
    response = stub_instagram_oauth_access_token(code)

    assert_difference "Signup.count" do
      get :callback, code: code
    end
    assert_redirected_to information_signup_path(Signup.first)
  end

  test '#callback with no account but existing signup associated with instagram_id' do
    code     = '123123123'
    signup   = Signup.create( instagram_id: '123', access_token: 'old-accesstoken', instagram_username: 'old-username')
    response = stub_instagram_oauth_access_token(code)

    assert_no_difference "Signup.count" do
      get :callback, code: code
    end
    assert_redirected_to information_signup_path(signup)

    signup.reload
    assert_equal response.access_token, decrypt(signup.access_token), 'must update access token with new token'
    assert_equal response.user.username, signup.instagram_username, 'must update username with current username'
  end

  test '#callback with existing account' do
    code     = '12312313123'
    response = stub_instagram_oauth_access_token(code)
    customer = create_customer(instagram_id: response.user.id)

    assert_difference "CustomerSession.count" do
      assert_no_difference "Signup.count" do
        get :callback, code: code
      end
    end
    assert_redirected_to dashboard_path
  end

  private

  def stub_instagram_oauth_access_token(code, response = nil)
    response = Hashie::Mash.new(response || default_instagram_oauth_access_token_response)
    Instagram.expects(:get_access_token)
             .with(code, redirect_uri: auth_instagram_callback_url)
             .returns(response)
    response
  end

  def default_instagram_oauth_access_token_response
    {
      access_token: 'my-access-token',
      user: {
        id: '123',
        username: 'jimsmith'
      }
    }
  end
end
