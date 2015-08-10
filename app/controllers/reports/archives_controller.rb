class Reports::ArchivesController < Reports::BaseController
  def update
    report = current_customer_report

    # TODO: try and charge customer a single report Payment::SINGLE_REPORT_IN_CENTS
    service = CreatePayment.call( customer: current_customer,
                                  amount: Payment::ARCHIVE_FEE )

    if payment = service.payment
      UnlockArchiveJob.perform_later payment
      flash[:notice] = "Thank you for your payment, your reports will be available soon."
    else
      # TODO: what do we do if we have failed payment
      flash[:error] = "Oops, we were unable to accept your payment.  We are busy looking into why."
    end
    redirect_to dashboard_path
  end
end
