# Responsible for building the Reports for
# a customer -- this should only be ran
# once for a customer.
#
# Use: #TODO: update with the class that will refresh reports
class CreateReportsJob < ActiveJob::Base
  queue_as :default

  include StrongboxMixin

  attr_reader :customer,
              :instagram_session

  attr_accessor :last_post_created_at

  delegate :timezone,
           :instagram_id,
           to: :customer

  def perform(*args)
    @customer             = args.first
    # TODO: store customer on instagram session (not required for all sessions)
    # TODO: record time in milliseconds it took InstagramSession to complete (easier to query slow responses)
    @instagram_session    = InstagramSession.create(access_token: decrypt(@customer.access_token))
    @last_post_created_at = nil
    @posts_meta           = {}

    set_timezone
    collect_post_data_from_instagram
    create_reports_from_posts_meta
    reset_timezone
    puts @posts_meta.inspect
  end

  private

  def collect_post_data_from_instagram
    instagram_session.user_media(instagram_id, max_timestamp: end_of_last_month_at_epoch).each do |post|
      posted_at = Time.zone.at(post.created_time.to_i)
      @last_post_created_at = posted_at
      @posts_meta[posted_at.year] ||= Array.new(12, 0)
      @posts_meta[posted_at.year][posted_at.month - 1]+=1
    end
  end

  def create_reports_from_posts_meta
    @posts_meta.each do |year, counts_by_month|
      counts_by_month.each_with_index do |count, index|
        month = index + 1
        RecordReportCount.call(customer: customer,
                               year: year,
                               month: month,
                               count: count)
      end
    end
  end

  def set_timezone
    @original_timezone = Time.zone
    Time.zone = timezone
  end

  def reset_timezone
    Time.zone = @original_timezone
  end

  def end_of_last_month_at_epoch
    Date.today.prev_month.end_of_month.to_time.to_i
  end

end
