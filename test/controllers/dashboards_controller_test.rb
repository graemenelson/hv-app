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
    c = create_customer(profile_created_at: 1.day.ago)
    create_customer_report(c, month: '05/2015', count: 3)
    create_customer_report(c, month: '04/2015', count: 0)
    create_customer_report(c, month: '03/2015', count: 15)
    create_customer_report(c, month: '02/2015', count: 12)
    create_customer_report(c, month: '01/2015', count: 9)
    create_customer_report(c, month: '12/2014', count: 2)
    create_customer_report(c, month: '11/2014', count: 1)

    signin_customer(c)
    get :show
    assert_response :ok
    assert_template :show
    assert assigns(:dashboard)
    assert_select "table", count: 2
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

  private

  def create_customer_report(customer, options = {})
    date = Date.parse(options.delete(:month))
    customer.reports.create(options.merge(month: date))
  end
end
