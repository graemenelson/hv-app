# A class to help find the most recent
# report with entries for the given
# customer.
#
# This class is used during the profile creation.
class MostRecentReportWithEntries

  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :customer,
              :report

  validates :customer, presence: true

  def self.call(attrs = {})
    self.new(attrs).call
  end

  def initialize(attrs = {})
    @customer = attrs[:customer]
  end

  def call
    if valid?
      @report = customer.reports.with_entries.first
    end
    self
  end

end
