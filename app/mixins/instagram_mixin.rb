module InstagramMixin

  def instagram(access_token)
    @instagram ||= ::Instagram.client( access_token: access_token )
  end

end
