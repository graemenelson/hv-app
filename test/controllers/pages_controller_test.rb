require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test '#landing' do
    get :landing
    assert_response :ok
  end
end
