module CurrentCustomer
  extend ActiveSupport::Concern

  def current_customer
    @current_customer ||= lookup_current_customer_from_session
  end

  def update_session_with_customer(customer)
    session[:customer_session_id] = CustomerSession.create(customer: customer,
                                                           visitor: current_visitor).id
    current_visitor.update_attribute(:customer, customer)
  end

  # before filter callback to ensure there's
  # a customer in the session
  def ensure_customer!
    unless current_customer
      # TODO: clean up customer not authorized
      render text: "Not allowed", status: :unauthorized
      false
    end
  end

  private

  def lookup_current_customer_from_session
    return nil unless customer_session = lookup_customer_session
    customer_session.update_attribute(:last_accessed_at, Time.now.utc)
    customer_session.customer
  end

  def lookup_customer_session
    customer_session = CustomerSession.find_by_id(session[:customer_session_id])
  end

end
