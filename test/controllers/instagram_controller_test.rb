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
    response = {
      access_token: 'my-access-token',
      user: {
        id: '123',
        username: 'jimsmith'
      }
    }
    stub_instagram_oauth_access_token(code, response)

    assert_difference "Signup.count" do
      get :callback, code: code
    end
  end

  private

  def stub_instagram_oauth_access_token(code, response)
    WebMock.stub_request(:post, "https://api.instagram.com/oauth/access_token/")
           .to_return(body: response.to_json.to_s)
  end
end
