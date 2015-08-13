require 'test_helper'

class CreateReportJobTest < ActiveJob::TestCase
  test '#perform with report' do
    customer = create_customer
    month    = Date.parse("May 2015")
    report   = customer.reports.create

    stub_create_report_posts(report)

    CreateReportJob.new.perform(report)
  end

  private

  def stub_create_report_posts(report)
    CreateReportPosts.expects(:call)
                     .with( report: report )
  end
end
