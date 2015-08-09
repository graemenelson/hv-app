namespace :shoryuken do

  namespace :queue do

    # reset the queues based on shoryuken.yml
    desc "reset the queues, remove and create"
    task reset: :environment do |t|
      fail "unable to run in production" if Rails.env.production?
      sqs    = Aws::SQS::Client.new(region: ENV['AWS_SQS_REGION'])
      Shoryuken.options[:queues].each do |(name, _)|
        sqs.create_queue(queue_name: "#{Rails.env}_#{name}")
      end
    end
  end
end
