require 'test_helper'

class UpdateInstagramStatsJobTest < ActiveJob::TestCase
  test '#perform with valid instagram user response' do
    customer  = create_customer
    instagram = stub_instagram(access_token: decrypt(customer.access_token))
    response  = valid_instagram_response
    instagram.expects(:user).returns(response)

    UpdateInstagramStatsJob.new.perform(customer)
    customer.reload

    assert_equal response.profile_picture, customer.instagram_profile_picture
    assert_equal response.full_name, customer.instagram_full_name
    assert_equal response.username, customer.instagram_username
    assert_equal response.website, customer.website
    assert_equal response.counts.followed_by, customer.instagram_followed_by_count
    assert_equal response.counts.follows, customer.instagram_follows_count
    assert_equal response.counts.media, customer.instagram_media_count
  end

  private

  def stub_instagram(options = nil)
    instagram = mock('instagram')
    ::Instagram.expects(:client)
               .with(options)
               .returns(instagram)
    instagram
  end

  def valid_instagram_response
    @response ||=
      Hashie::Mash.new(
        counts: { followed_by: 10, follows: 20, media: 166 },
        profile_picture: 'http://path/to/new/profile.pic',
        full_name: 'Jill Smith New',
        username: 'jillsmithnew',
        website: 'http://see/my/stuff/here'
        )
  end
end
