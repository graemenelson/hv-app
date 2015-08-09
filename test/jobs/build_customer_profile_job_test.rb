require 'test_helper'

class BuildCustomerProfileJobTest < ActiveJob::TestCase
  test '#perform should call supporting jobs with customer' do
    customer = create_customer
    report   = customer.reports.create( count: 1 )
    stub_update_instagram_stats_job(customer)
    stub_create_reports_job(customer)
    stub_create_report_job(report)
    BuildCustomerProfileJob.new.perform(customer)
    assert customer.profile_created_at.present?
    assert customer.first_posted_at.present?
    assert_equal customer.current_subscription,
                 report.purchaseable
  end

  def stub_update_instagram_stats_job(customer)
    job = mock('update-instragram-stats-job')
    job.expects(:perform).with(customer)

    UpdateInstagramStatsJob.expects(:new).returns(job)
  end

  def stub_create_reports_job(customer)
    job = mock('create-reports-job')
    job.expects(:perform).with(customer).returns(Hashie::Mash.new(first_post_created_at: 1.day.ago))

    CreateReportsJob.expects(:new).returns(job)
  end

  def stub_create_report_job(report)
    CreateReportJob.expects(:perform_later).with(report)
  end

end
