require 'test_helper'

class RecordReportCountTest < ActiveSupport::TestCase
  test "valid attributes with no existing report" do
    customer   = create_customer
    last_month = Date.today.prev_month

    assert_difference "Report.count" do
      service = RecordReportCount.call(
                    customer: customer,
                    month: last_month.month,
                    year:  last_month.year,
                    count: 3)
      assert service.valid?
      assert_equal 3, service.report.count
    end
  end
  test 'valid attributes with existing report' do
    customer = create_customer
    RecordReportCount.call(customer: customer, month: 1, year: 2013, count: 3 )
    assert_no_difference "Report.count" do
      service = RecordReportCount.call(
                    customer: customer,
                    month: 1,
                    year: 2013,
                    count: 2)

      assert service.valid?
      assert_equal 2, service.report.count
    end
  end

  test 'invalid attributes with no report' do
    customer = create_customer
    today    = Date.today

    assert_no_difference "Report.count" do
      service = RecordReportCount.call(
                  customer: customer,
                  month: today.month,
                  year:  today.year,
                  count: 2
      )
      refute service.valid?
      assert_error(service, :base)
    end
  end


end
