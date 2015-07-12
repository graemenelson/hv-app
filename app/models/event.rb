class Event < ActiveRecord::Base
  belongs_to :visitor
  belongs_to :customer
end
