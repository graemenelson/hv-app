module EventTracking
  extend ActiveSupport::Concern

  def track!(name, options = {})
    # TODO: extract customer from visitor, once customer is available
    Event.create(
      action: name,
      visitor: options[:visitor],
      ip: request.ip,
      path: request.path,
      referrer: request.referrer,
      parameters: request.query_parameters,
      user_agent: request.headers['HTTP_USER_AGENT'],
      app_version: Version.current
    )
  end

end
