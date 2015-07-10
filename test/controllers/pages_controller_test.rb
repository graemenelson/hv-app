require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  test '#landing' do
    landing_event_count = ->{ Event.where(action: 'landing').count }
    
    assert_difference landing_event_count do
      get :landing
    end
    assert_response :ok
  end
end
