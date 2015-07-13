module EventTracking
  extend ActiveSupport::Concern

  def track!(name, options = {})
    parameters = options[:parameters] || {}
    visitor    = options[:visitor]
    customer   = visitor.present? ? visitor.customer : nil
    Event.create(
      action: name,
      visitor: options[:visitor],
      customer: customer,
      ip: request.ip,
      path: request.path,
      referrer: request.referrer,
      parameters: parameters.merge(request.query_parameters),
      user_agent: request.headers['HTTP_USER_AGENT'],
      app_version: Version.current
    )
  end

end
