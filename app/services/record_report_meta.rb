# Responsible for recording the report count
# for a given consumer, year, and month.
#
# It will not allow recording for reports
# that are in the current or future months.
class RecordReportMeta

  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_reader :customer,
              :month,
              :year,
              :count,
              :min_timestamp,
              :max_timestamp,
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
    @min_timestamp = attrs[:min_timestamp]

    # we add +1 to the max timestamp, otherwise the user media lookup will
    # not match when max timestamp is a complete match. TODO: make sure this is the case
    @max_timestamp = attrs[:max_timestamp].present? ?
                     attrs[:max_timestamp].to_i + 1 :
                     nil

    @date     = Date.parse("#{month}/#{year}")
  end

  def call
    if valid?
      updateable_attrs = { count: count,
                           min_timestamp: min_timestamp,
                           max_timestamp: max_timestamp }
      if @report = customer.reports.find_by(month: date)
        @report.update_attributes(updateable_attrs)
      else
        @report = customer.reports.create!(updateable_attrs.merge(month: date))
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
