module CurrentVisitor
  extend ActiveSupport::Concern

  def current_visitor
    @current_visitor ||= lookup_or_create_visitor
  end

  def lookup_or_create_visitor
    lookup_visitor(session[:visitor_id]) || create_visitor
  end

  def lookup_visitor(id)
    Visitor.find_by_id(id)
  end

  def create_visitor
    visitor = Visitor.create(
        ip: request.ip,
        path: request.path,
        user_agent: request.headers['HTTP_USER_AGENT'],
        referrer: request.referrer,
        parameters: request.query_parameters
      )
    session[:visitor_id] = visitor.try(:id)
    visitor
  end

end
