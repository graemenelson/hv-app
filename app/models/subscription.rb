class Subscription < ActiveRecord::Base
  belongs_to :customer
  belongs_to :plan

  validates :start_date,
            :end_date,
            presence: true
end
