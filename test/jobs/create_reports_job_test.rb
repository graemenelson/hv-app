require 'test_helper'

class CreateReportsJobTest < ActiveJob::TestCase

  test 'with instagram session with user media' do
    customer = create_customer
    job      = CreateReportsJob.new
    media    = user_media
    stub_instagram_session_user_media(job, media)

    job.perform(customer)

    assert_equal Time.at(media.last.created_time.to_i),
                 job.first_post_created_at

    # June 2015
    assert_report_count(customer, "Jun 2015", 1)
    assert_report_min_timestamp(customer, "Jun 2015", media[0])
    assert_report_max_timestamp(customer, "Jun 2015", media[0])

    # May 2015
    assert_report_count(customer, "May 2015", 2)
    assert_report_min_timestamp(customer, "May 2015", media[2])
    assert_report_max_timestamp(customer, "May 2015", media[1])

    # Oct 2014
    assert_report_count(customer, "Oct 2014", 1)
    assert_report_min_timestamp(customer, "Oct 2014", media[3])
    assert_report_max_timestamp(customer, "Oct 2014", media[3])
  end

  private

  def user_media
    [
      Hashie::Mash.new( created_time: Time.parse("2015-06-03").to_i.to_s ),
      Hashie::Mash.new( created_time: Time.parse("2015-05-30").to_i.to_s ),
      Hashie::Mash.new( created_time: Time.parse("2015-05-15").to_i.to_s ),
      Hashie::Mash.new( created_time: Time.parse("2014-10-20").to_i.to_s )
    ]
  end

  def assert_report_count(customer, month, count)
    assert_equal count,
                 customer_report_for_month(customer, month).count
  end

  def assert_report_min_timestamp(customer, month, post)
    assert_equal post.created_time.to_i,
                 customer_report_for_month(customer, month).min_timestamp
  end

  # we add +1 to the max timestamp, otherwise the user media lookup will
  # not match when max timestamp is a complete match. TODO: make sure this is the case
  def assert_report_max_timestamp(customer, month, post)
    assert_equal post.created_time.to_i + 1,
                 customer_report_for_month(customer, month).max_timestamp
  end

  def customer_report_for_month(customer, month)
    customer.reports.where(month: Date.parse(month)).take
  end

end
