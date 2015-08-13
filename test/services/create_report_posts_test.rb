require 'test_helper'

class CreateReportPostsTest < ActiveSupport::TestCase
  test '#call with report' do
    customer = create_customer
    month    = Date.parse("May 2015")
    report   = customer.reports.create( count: 2,
                                        month: month,
                                        min_timestamp: month.beginning_of_month.to_time.to_i,
                                        max_timestamp: month.end_of_month.to_time.to_i)

    service = CreateReportPosts.new(report: report)
    media = user_media
    stub_instagram_session_user_media(service, media)

    assert_difference "Post.count" do
      assert_difference "Comment.count" do
        service.call
      end
    end

    refute_nil report.reload.build_posts_finished_at
  end

  private

  def user_media
    [
      Hashie::Mash.new( comments: { data: [
                                      Hashie::Mash.new( from: {username: "jillpdx"})
                                    ],
                                    count: 0 },
                        likes: { count: 2 },
                        link: '/path/to/post',
                        images: {
                          standard_resolution: {
                            url: '/path/to/image'
                          }
                        },
                        created_time: Time.parse("2015-06-03").to_i.to_s )
    ]
  end

end
