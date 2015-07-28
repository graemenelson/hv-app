class CreateReportJob < ActiveJob::Base
  queue_as :default

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

  def perform(*args)
    # TODO: need to transiation report into a building stage, and then move
    # to download stage once report is done.
    @report             = args.first
    @instagram_session  = instagram(decrypt(customer.access_token))

    set_timezone
    process
    reset_timezone

    self
  end

  private

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
