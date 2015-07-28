# A class to help find the most recent
# report with entries for the given
# customer.
#
# This class is used during the profile creation.
class MostRecentReportWithEntries < BaseService

  attr_reader :customer,
              :report

  validates :customer, presence: true

  def initialize(attrs = {})
    @customer = attrs[:customer]
  end

  def perform
    @report = customer.reports.with_entries.first
  end

end
