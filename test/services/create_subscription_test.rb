require 'test_helper'

class CreateSubscriptionTest < ActiveSupport::TestCase
  test '#call with validation errors' do
    service = CreateSubscription.call({})
    refute service.valid?
    assert_error(service, :customer)
    assert_error(service, :plan)
    assert_error(service, :transaction_id)
  end
  test '#call with valid attributes and starts_at' do
    customer       = create_customer
    plan           = create_plan(duration: 6)
    transaction_id = '123123'
    service        = CreateSubscription.call( customer: customer,
                                             plan: plan,
                                             transaction_id: transaction_id,
                                             starts_at: 1.month.ago )

    assert service.valid?


    subscription = service.subscription
    assert_equal customer, subscription.customer
    assert_equal plan, subscription.plan
    assert_equal transaction_id, subscription.transaction_id

    with_timezone(customer.timezone) do
      assert_equal 1.month.ago.beginning_of_month, subscription.starts_at
      assert_equal 4.months.from_now.end_of_month, subscription.ends_at
    end

  end


end
