class CreateSubscription

  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :customer,
              :transaction_id,
              :plan,
              :starts_at,
              :subscription

  validates :customer,
            :plan,
            :transaction_id, presence: true

  def self.call(attrs = {})
    self.new(attrs).call
  end

  def initialize(attrs = {})
    @customer = attrs[:customer]
    @transaction_id = attrs[:transaction_id]
    @plan = attrs[:plan]
    @starts_at = attrs[:starts_at] || Time.zone.now
  end

  def call
    if valid?
      @subscription = customer.subscriptions.create!( plan: plan,
                                                      transaction_id: transaction_id,
                                                      starts_at: subscription_starts_at,
                                                      ends_at: subscription_ends_at )
    end
    self
  end

  private

  def subscription_starts_at
    with_customer_timezone do
      # must convert starts_at to the timezone of the customer
      starts_at.in_time_zone(customer.timezone).beginning_of_month
    end
  end
  def subscription_ends_at
    # TODO: improve readability of the ends_at calculation for subsscription
    #       -- you go one month back and take the plan duration minus 1
    with_customer_timezone do
      (1.month.ago + (plan.duration-1).months).end_of_month
    end
  end

  def with_customer_timezone(&block)
    current_timezone = Time.zone
    Time.zone = customer.timezone
    result = yield
    Time.zone = current_timezone
    result
  end

end
