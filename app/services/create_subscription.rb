class CreateSubscription

  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :customer,
              :transaction_id,
              :plan,
              :start_date,
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
    @start_date = attrs[:start_date] || Date.today
  end

  def call
    if valid?
      @subscription = customer.subscriptions.create!( plan: plan,
                                                      transaction_id: transaction_id,
                                                      start_date: subscription_start_date,
                                                      end_date: subscription_end_date )
    end
    self
  end

  private

  def subscription_start_date
    start_date.beginning_of_month
  end

  def subscription_end_date
    # TODO: improve readability of the ends_at calculation for subsscription
    #      -- you go one month back and take the plan duration minus 1
    (1.month.ago + (plan.duration-1).months).end_of_month
  end
end
