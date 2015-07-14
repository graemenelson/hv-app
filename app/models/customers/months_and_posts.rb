module Customers
  # A helper class to track whether a month has posts or not.
  #
  # After iterating over the User's recent media feed, this class
  # will help iterate over the range of months with posts.  It will
  # ignore all any months that have no posts, unless they happen between
  # months with posts.
  class MonthsAndPosts

    class MonthPosts
      def initialize(month, has_posts)
        @month     = month
        @has_posts = has_posts
      end
      def has_posts?
        @has_posts
      end
      def no_posts?
        !has_posts?
      end
    end

    attr_reader :customer,
                :current_month

    delegate :each, to: :months_and_posts_sanitized

    # Requires a customer.
    #
    # If no current_month is given then we default to the prev_month from today.
    def initialize(customer, current_month = nil)
      @customer         = customer
      @current_month    = current_month || Date.today.prev_month
      @months_and_posts = []
    end

    # Records whether the current month has
    # posts or not. And updates the current
    # month to be the previous month from the
    # current month.
    #
    # Returns the previous month
    def current_month_has_posts(true_or_false)
      @months_and_posts.push(MonthPosts.new(current_month, true_or_false))
      @current_month = current_month.prev_month
    end

    # Returns the "number of seconds from Epoch" based on beginning of the month and
    # the timezone for the consumer.
    #
    # This value will be used in the user recent media lookup on Instagram
    def current_timestamp_for_instagram
      with_customer_timezone do
        Time.zone.parse("#{current_month.month}/#{current_month.year}").to_i
      end
    end

    private

    attr_reader :months_and_posts

    def with_customer_timezone(&block)
      current_timezone = Time.zone
      Time.zone = customer.timezone || 'UTC'
      result = yield
      Time.zone = current_timezone
      result
    end

    def months_and_posts_sanitized
      @months_and_posts_sanitized ||= build_sanitized_months_and_posts
    end

    # Responsible for removing all of the last entries of the array until we
    # hit a month with posts.
    def build_sanitized_months_and_posts
      array = months_and_posts.clone
      while array.last.no_posts? do
        array.pop
      end
      array.freeze
    end

  end
end
