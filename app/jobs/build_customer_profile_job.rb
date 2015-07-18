class BuildCustomerProfileJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    customer = args.first
    UpdateInstagramStatsJob.new.perform(customer)
    # TODO: iterate through customer feed one month at a time
    #       -- keep track of months with images or not
    #       -- remove all ending months with no images

    customer.update_attribute(:profile_created_at, Time.zone.now)
  end
end
