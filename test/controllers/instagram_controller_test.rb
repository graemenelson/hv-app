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
end
