class CreateReportPosts < BaseService

  include InstagramMixin
  include StrongboxMixin
  include TimezoneMixin

  attr_reader :report,
              :instagram_session

  delegate :customer,
           :max_timestamp,
           :min_timestamp,
           to: :report

  delegate :timezone,
           :instagram_id,
           to: :customer

  def initialize(attrs = {})
    @report             = attrs[:report]
    @instagram_session  = instagram(decrypt(customer.access_token))
  end

  def perform
    set_timezone
    process
    record_build_posts_finished_at
    reset_timezone
  end

  private

  def record_build_posts_finished_at
    report.update_attribute(:build_posts_finished_at, Time.zone.now)
  end

  def process
    instagram_session.user_media(instagram_id,
                                 max_timestamp: max_timestamp,
                                 min_timestamp: min_timestamp).each do |media|

      process_media(media)
    end
    instagram_session.close!
  end

  def process_media(media)
    comments_count = media.comments[:count]
    comments       = media.comments.data

    post = report.posts.create({
        media_id: media.id,
        comments_count: comments_count,
        likes_count: media.likes[:count],
        created_at: Time.at(media.created_time.to_i),
        caption: media.caption ? media.caption.text : nil,
        url: media.link,
        media_type: 'image',
        media_url: media.images.standard_resolution.url
      })

    comments.each do |comment|
      post.comments.create({
          username: comment.from.username,
          profile_picture: comment.from.profile_picture,
          text:            comment.text,
          created_at:      Time.at(comment.created_time.to_i)
        })
    end

    post
  end

end
