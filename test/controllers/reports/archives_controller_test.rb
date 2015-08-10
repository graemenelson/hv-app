require 'test_helper'

class Reports::ArchivesControllerTest < ActionController::TestCase
  test '#update with a purchaseable report' do
    customer = create_customer
    report_1 = customer.reports.create( count: 1, month: 3.months.ago )
    report_2 = customer.reports.create( count: 2, month: 4.months.ago )
    payment  = customer.payments.create( amount_cents: 2000, transaction_id: 'transaction' )

    UnlockArchiveJob.expects(:perform_later).with(payment)

    stub_create_payment({
        customer: customer,
        amount:   Payment::ARCHIVE_FEE
      }, Hashie::Mash.new(payment: payment))

    signin_customer(customer)
    put :update, report_id: report_1

    assert_redirected_to dashboard_path
  end

  private

  def stub_create_payment(attrs, response)
    CreatePayment.expects(:call)
                 .with(attrs)
                 .returns(response)
  end
end
