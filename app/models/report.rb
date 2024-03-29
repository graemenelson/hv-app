class Report < ActiveRecord::Base
  default_scope { order('month DESC') }

  has_many :posts
  belongs_to :customer
  belongs_to :purchaseable, polymorphic: true

  scope :with_entries,  -> { where('count > 0') }
  scope :not_purchased, -> { where('purchased_at is null') }
  scope :archived,      -> { not_purchased.with_entries }
end
