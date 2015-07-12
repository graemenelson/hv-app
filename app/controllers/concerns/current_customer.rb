module CurrentCustomer
  extend ActiveSupport::Concern

  def current_customer(customer = nil)
    @current_customer ||= lookup_current_customer
  end

  def current_customer=(customer)

    # TODO: need to ensure we set in current visitor if not set yet
    @current_customer = customer
  end

end
