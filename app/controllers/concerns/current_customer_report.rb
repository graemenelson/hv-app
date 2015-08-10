module CurrentCustomerReport
  extend ActiveSupport::Concern

  def current_customer_report
    @current_customer_report ||= lookup_customer_report_from_params
  end

  def ensure_customer_report!
    unless current_customer_report
      render text: "Not allowed", status: :unauthorized
      false
    end
  end

  private

  def lookup_customer_report_from_params
    current_customer.reports.find_by_id( params[:report_id] )
  end

end
