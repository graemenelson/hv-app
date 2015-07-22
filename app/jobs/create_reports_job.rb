# Responsible for building the Reports for
# a customer -- this should only be ran
# once for a customer.
#
# Use: #TODO: update with the class that will refresh reports
class CreateReportsJob < ActiveJob::Base
  queue_as :default

  include InstagramMixin
  include StrongboxMixin

  attr_reader :customer,
              :instagram_session

  delegate :timezone,
           :instagram_id,
           to: :customer

  delegate :first_post_created_at,
           to: :posts_meta

  class MonthMeta
    attr_reader :year,
                :month,
                :count,
                :max_timestamp,
                :min_timestamp

    def initialize(year, month)
      @year  = year
      @month = month
      @count = 0
    end

    def record(post)
      @count += 1

      @max_timestamp = post.created_time unless max_timestamp
      @min_timestamp = post.created_time
    end
  end

  class PostsMeta

    attr_reader :first_post_created_at

    delegate :each,
             to: :flatten_meta

    def initialize
      @first_post_created_at = nil
      @meta                  = {}
    end

    def record(post)
      posted_at = Time.zone.at(post.created_time.to_i)
      build_months_for_year(posted_at.year)
      record_post(post)
      @first_post_created_at = posted_at
    end


    private

    def build_months_for_year(year)
      unless @meta[year].present?
        @meta[year] = 1.upto(12).collect {|month| MonthMeta.new(year, month) }
      end
    end

    def record_post(post)
      posted_at = Time.zone.at(post.created_time.to_i)
      @meta[posted_at.year][posted_at.month-1].record(post)
    end

    def flatten_meta
      years = @meta.keys.sort.reverse
      years.collect do |year|
        @meta[year]
      end.flatten
    end
  end

  def perform(*args)
    @customer             = args.first
    # TODO: store customer on instagram session (not required for all sessions)
    # TODO: record time in milliseconds it took InstagramSession to complete (easier to query slow responses)
    @instagram_session    = instagram(decrypt(@customer.access_token))
    @posts_meta           = PostsMeta.new

    set_timezone
    collect_post_data_from_instagram
    create_reports_from_posts_meta
    reset_timezone

    self
  end

  private

  attr_reader :posts_meta

  def collect_post_data_from_instagram
    instagram_session.user_media(instagram_id, max_timestamp: end_of_last_month_at_epoch).each do |post|
      posts_meta.record(post)
    end
  end

  def create_reports_from_posts_meta
    posts_meta.each do |month_meta|
      RecordReportMeta.call(customer: customer,
                             year: month_meta.year,
                             month: month_meta.month,
                             count: month_meta.count,
                             min_timestamp: month_meta.min_timestamp,
                             max_timestamp: month_meta.max_timestamp)
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
