class CustomerSession < ActiveRecord::Base
  belongs_to :customer
  belongs_to :visitor
end
