class BuildCustomerProfileJob < ActiveJob::Base
  queue_as :high_priority

  def perform(*args)
    customer = args.first
    stats   = UpdateInstagramStatsJob.new.perform(customer)
    reports = CreateReportsJob.new.perform(customer)

    service  = MostRecentReportWithEntries.call(customer: customer)
    if report = service.report
      report.update_attribute(:purchaseable, customer.current_subscription)
      CreateReportJob.perform_later(service.report)
    end

    # TODO: kick off first subscription based report for last month
    #       -- if last month does not have photos, find the previous month with
    #          photos

    customer.update_attributes(first_posted_at: reports.first_post_created_at,
                               profile_created_at: Time.zone.now)
  end
end
