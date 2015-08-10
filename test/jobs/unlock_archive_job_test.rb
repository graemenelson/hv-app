require 'test_helper'

class UnlockArchiveJobTest < ActiveJob::TestCase
  test "#perform unlock all archived reports for payment customer" do
    customer = create_customer
    payment  = customer.payments.create

    report_1 = customer.reports.create(count: 0)
    report_2 = customer.reports.create(count: 1)
    report_3 = customer.reports.create(count: 2, purchaseable: payment, purchased_at: 1.day.ago)
    report_4 = customer.reports.create(count: 3)

    stub_create_report_job(report_2)
    stub_create_report_job(report_4)
    UnlockArchiveJob.new.perform(payment)

    report_2.reload
    assert_equal payment, report_2.purchaseable
    refute_nil report_2.purchased_at

    report_4.reload
    assert_equal payment, report_4.purchaseable
    refute_nil report_4.purchased_at
  end

  private

  def stub_create_report_job(report)
    CreateReportJob.expects(:perform_later)
                   .with(report)
  end
end
