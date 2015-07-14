class UpdateInstagramStatsJob < ActiveJob::Base
  queue_as :instagram

  include InstagramMixin

  def perform(*args)
    customer = args.first
    response = instagram(customer.access_token).user
    customer.update_attributes(customer_attributes_from_response(response))
  end

  private

  def customer_attributes_from_response(response)
    attributes = {
      instagram_profile_picture: response.profile_picture,
      instagram_username: response.username,
      instagram_full_name: response.full_name,
      website: response.website,
      instagram_follows_count: response.counts.follows,
      instagram_followed_by_count: response.counts.followed_by,
      instagram_media_count: response.counts.media
    }
  end
end
