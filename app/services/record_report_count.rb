# Responsible for recording the report count
# for a given consumer, year, and month.
#
# It will not allow recording for reports
# that are in the current or future months.
class RecordReportCount

  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :customer,
              :month,
              :year,
              :count,
              # Out
              :date,
              :report

  validate :date_is_in_past?

  def self.call(attrs={})
    self.new(attrs).call
  end

  def initialize(attrs={})
    @customer = attrs[:customer]
    @month    = attrs[:month]
    @year     = attrs[:year]
    @count    = attrs[:count]

    @date     = Date.parse("#{month}/#{year}")
  end

  def call
    if valid?
      if @report = customer.reports.find_by(month: date)
        @report.update_attribute(:count, count)
      else
        @report = customer.reports.create! month: date,
                                           count: count
      end
    end

    self
  end

  private

  def date_is_in_past?
    unless date < Date.today.beginning_of_month
      errors.add(:base, "month and year must be in the past")
    end
  end

end
