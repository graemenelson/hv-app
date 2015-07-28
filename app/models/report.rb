class Report < ActiveRecord::Base
  default_scope { order('month DESC') }

  has_many :posts
  belongs_to :customer

  scope :with_entries, -> { where('count > 0') }
end
