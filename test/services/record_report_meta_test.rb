require 'test_helper'

class RecordReportMetaTest < ActiveSupport::TestCase
  test "valid attributes with no existing report" do
    customer   = create_customer
    last_month = Date.today.prev_month

    assert_difference "Report.count" do
      service = RecordReportMeta.call(
                    customer: customer,
                    month: last_month.month,
                    year:  last_month.year,
                    count: 3,
                    min_timestamp: 4.days.ago.to_i,
                    max_timestamp: 2.days.ago.to_i)
      assert service.valid?
      assert_equal 3, service.report.count
    end
  end
  test 'valid attributes with existing report' do
    customer = create_customer
    RecordReportMeta.call(customer: customer, month: 1, year: 2013, count: 3 )
    assert_no_difference "Report.count" do
      service = RecordReportMeta.call(
                    customer: customer,
                    month: 1,
                    year: 2013,
                    count: 2,
                    min_timestamp: 3.days.ago.to_i,
                    max_timestamp: 1.day.ago.to_i)

      assert service.valid?
      assert_equal 2, service.report.count
    end
  end

  test 'invalid attributes with no report' do
    customer = create_customer
    today    = Date.today

    assert_no_difference "Report.count" do
      service = RecordReportMeta.call(
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
