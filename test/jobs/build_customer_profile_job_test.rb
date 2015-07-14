require 'test_helper'

class BuildCustomerProfileJobTest < ActiveJob::TestCase
  test '#perform should call supporting jobs with customer' do
    customer = Object.new
    stub_update_instagram_stats_job(customer)

    BuildCustomerProfileJob.new.perform(customer)
  end

  def stub_update_instagram_stats_job(customer)
    job = mock('update-instragram-stats-job')
    job.expects(:perform).with(customer)

    UpdateInstagramStatsJob.expects(:new).returns(job)
  end

end
