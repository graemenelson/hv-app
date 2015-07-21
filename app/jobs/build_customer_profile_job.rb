class BuildCustomerProfileJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    customer = args.first
    UpdateInstagramStatsJob.new.perform(customer)
    CreateReportsJob.new.perform(customer)
    # TODO: kick off first subscription based report for last month
    #       -- if last month does not have photos, find the previous month with
    #          photos

    customer.update_attribute(:profile_created_at, Time.zone.now)
  end
end
