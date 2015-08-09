require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test '#most_recent_report_with_counts with first report having counts' do
    customer = create_customer
    r1 = customer.reports.create(month: 1.month.ago, count: 2)
    r2 = customer.reports.create(month: 2.months.ago, count: 1)

    assert_equal r1, customer.most_recent_report_with_counts
  end
  test '#most_recent_report_with_counts with first report has a count of 0' do
    customer = create_customer
    r1 = customer.reports.create(month: 1.month.ago, count: 0)
    r2 = customer.reports.create(month: 2.months.ago, count: 1)

    assert_equal r2, customer.most_recent_report_with_counts
  end
  test '#current_subscription with a current subscription' do
    customer = create_customer
    subscription = customer.subscriptions.create( start_date: 30.days.ago, end_date: 1.day.from_now )
    assert_equal subscription, customer.current_subscription
  end
  test '#current_subscription with old subscription' do
    customer = create_customer
    subscription = customer.subscriptions.create( start_date: 30.days.ago, end_date: 1.day.ago )
    assert_nil customer.current_subscription
  end
  test '#current_subscription with future subscription' do
    customer = create_customer
    subscription = customer.subscriptions.create( start_date: 1.day.from_now, end_date: 20.days.from_now)
    assert_nil customer.current_subscription
  end
  test '#current_subscription with no subscriptions' do
    customer = create_customer
    assert_nil customer.current_subscription
  end
end
