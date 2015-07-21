class Report < ActiveRecord::Base
  default_scope { order('month DESC') }

  belongs_to :customer
end
