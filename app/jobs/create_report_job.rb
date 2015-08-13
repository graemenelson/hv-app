class CreateReportJob < ActiveJob::Base
  queue_as :default

  attr_reader :report

  def perform(*args)
    @report             = args.first

    CreateReportPosts.call( report: report )
    # TODO: should kick off a generate pdf job for report
    
    self
  end

end
