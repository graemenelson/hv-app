class BuildCustomerProfileJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    customer = args.first
    UpdateInstagramStatsJob.new.perform(customer)
    RetrieveNewInstagramPostsJob.new.perform(customer)
  end
end
