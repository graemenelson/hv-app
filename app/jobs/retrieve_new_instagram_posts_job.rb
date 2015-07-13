class RetrieveNewInstagramPostsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    customer = args.first
  end
end
