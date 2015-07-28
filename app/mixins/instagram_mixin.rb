module InstagramMixin

  def instagram(access_token)
    @instagram ||= InstagramSession.create(access_token: access_token)
  end

end
