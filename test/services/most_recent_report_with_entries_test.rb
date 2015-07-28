require 'test_helper'

class MostRecentReportWithEntriesTest < ActiveSupport::TestCase
  test '#call with a customer with a report with entries' do
    customer = create_customer
    report   = customer.reports.create( count: 1 )
    service  = MostRecentReportWithEntries.call(customer: customer)
    assert service.valid?
    assert_equal report, service.report
  end
  test '#call with a customer with a report with no entries' do
    customer = create_customer
    report   = customer.reports.create( count: 0 )
    service  = MostRecentReportWithEntries.call(customer: customer)
    assert service.valid?
    assert_nil service.report
  end
  test '#call with no customer' do
    service = MostRecentReportWithEntries.call({})
    refute service.valid?
    assert_error(service, :customer)
  end
end
