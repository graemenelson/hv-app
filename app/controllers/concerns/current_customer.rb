module CurrentCustomer
  extend ActiveSupport::Concern

  def current_customer(customer = nil)
    @current_customer ||= lookup_current_customer
  end

  # :nodoc:
  # should use update_session_with_customer, to ensure
  # visitor customer get set
  def current_customer=(customer)
    @current_customer = customer
  end

  def update_session_with_customer(customer)
    self.current_customer = customer
    current_visitor.update_attribute(:customer, customer)
  end

end
