class Customer < ActiveRecord::Base

  has_many :subscriptions
  belongs_to :signup
end
