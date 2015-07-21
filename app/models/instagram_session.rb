require 'benchmark'
class InstagramSession < ActiveRecord::Base

  include StrongboxMixin

  encrypt_with_public_key :access_token,
      key_pair: Rails.root.join('config','certs','keypair.pem'),
      base64: true

  has_many :logs, class_name: "InstagramSessionLog"

  serialize :backtrace

  # Retrieves the media for the given instagram user id (`id`),
  # based on other options given.
  #
  # See: https://instagram.com/developer/endpoints/users/#get_users_media_recent
  #
  # Laziness supported like so:
  #
  #  InstagramSession.new().user_media(1323).lazy.first(5)
  def user_media(id, options = {})
    last_page = false

    Enumerator.new do |yielder|
      begin
        loop do
          raise StopIteration if last_page

          log  = build_log(:user_recent_media, [id, options])

          response = lookup_user_media(id, options, log)
          log.close!

          response.each {|post| yielder.yield post }

          if next_max_id = response.pagination.next_max_id
            options[:max_id] = next_max_id
          else
            last_page = true unless response.pagination.next_max_id
          end
        end
      rescue Exception => e
        close!(e)
        raise e if Rails.env.test?
        []
      end
      close!
    end
  end

  def comments(id)
    log = build_log(:comments, [id])

    response = lookup_comments(id, log)
  end

  def close!(exception = nil)
    finished_at = Time.now
    attrs = { finished_at: finished_at,
              milliseconds_to_finish: (finished_at - created_at)*1000 }
    if exception
      attrs.merge!(
        error:        exception.message,
        backtrace:    exception.backtrace
      )
    end
    update_attributes(attrs)
  end

  private

  def client
    Instagram.client( access_token: decrypted_access_token )
  end

  def decrypted_access_token
    @decrypted_access_token ||= decrypt(access_token)
  end

  def build_log(endpoint, params)
    self.logs.build( created_at: Time.now.utc,
                     endpoint: endpoint,
                     params: params )
  end

  def lookup_user_media(id, options, log)
    results = nil
    time = Benchmark.realtime do
      results = client.user_recent_media(id, options)
    end
    log.response_time = time * 1000 # in milliseconds
    results
  end

  def lookup_comments(id, log)
    results = nil
    time = Benchmark.realtime do
      results = client.media_comments(id)
    end
    log.response_time = time * 1000 # in milliseconds
    log.close!
    results
  end

end
