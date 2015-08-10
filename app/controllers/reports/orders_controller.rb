class Reports::OrdersController < Reports::BaseController
  before_filter :ensure_customer!
  before_filter :ensure_customer_report!

  def show
    @report = current_customer_report
  end

  def update
    report = current_customer_report

    # TODO: try and charge customer a single report Payment::SINGLE_REPORT_IN_CENTS
    service = CreatePayment.call( customer: current_customer,
                                  amount: Payment::SINGLE_REPORT_FEE )

    if payment = service.payment
      report.update_attributes(purchaseable: payment,
                                purchased_at: Time.zone.now)
      CreateReportJob.perform_later(report)
      flash[:notice] = "Thank you for your payment, your report will be available soon."
    else
      # TODO: what do we do if we have failed payment
      flash[:error] = "Oops, we were unable to accept your payment.  We are busy looking into why."
    end
    redirect_to dashboard_path
  end
end
