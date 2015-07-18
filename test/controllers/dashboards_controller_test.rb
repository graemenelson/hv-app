require 'test_helper'

class DashboardsControllerTest < ActionController::TestCase
  test '#build with customer without their profile' do
    signin_customer(create_customer)
    get :build
    assert_response :ok
    assert_template :build
  end
  test '#build with customer with their profile' do
    signin_customer(create_customer(profile_created_at: 1.day.ago))
    get :build
    assert_redirected_to dashboard_path
  end
  test '#build with no customer' do
    get :build
    assert_response :unauthorized
  end

  test '#show with customer with profile' do
    signin_customer(create_customer(profile_created_at: 1.day.ago))
    get :show
    assert_response :ok
    assert_template :show
  end
  test '#show customer with no profile' do
    signin_customer(create_customer)
    get :show
    assert_redirected_to build_dashboard_path
  end
  test '#show with no customer' do
    get :show
    assert_response :unauthorized
  end
end
