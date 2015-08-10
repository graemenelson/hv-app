class Payment < ActiveRecord::Base
  SINGLE_REPORT_FEE = "3.00"
  ARCHIVE_FEE       = "20.00"

  belongs_to :customer
end
