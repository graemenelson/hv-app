class Subscription < ActiveRecord::Base
  belongs_to :customer
  belongs_to :plan

  validates :starts_at,
            :ends_at,
            presence: true
end
