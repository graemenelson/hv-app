module InstagramMixin

  def instagram(access_token)
    @instagram ||= InstagramSession.new(access_token: access_token)
  end

end
