class UnlockArchiveJob < ActiveJob::Base
  queue_as :high_priority

  attr_reader :payment

  delegate :customer,
           to: :payment

  def perform(*args)
    @payment = args.first

    customer.reports.archived.each do |report|
      report.update_attributes(purchaseable: payment,
                                purchased_at: Time.zone.now)
      CreateReportJob.perform_later(report)
    end
  end
end
