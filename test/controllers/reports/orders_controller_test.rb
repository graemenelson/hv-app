require 'test_helper'

class Reports::OrdersControllerTest < ActionController::TestCase
  test '#show with a purchaseable report' do
    customer = create_customer
    report   = customer.reports.create( count: 1 )

    signin_customer(customer)
    get :show, report_id: report
    assert_response :ok
    assert_template :show
    assert_equal report, assigns(:report)

    assert_select "a[href='#{report_order_path(report)}'][data-method='put']"
    #assert_select "a[href='#{archive_purchase_path(report_id: report.id)}']"
  end

  test '#update with a purchaseable report' do
    customer = create_customer
    report   = customer.reports.create( count: 1 )
    payment  = customer.payments.create( amount_cents: 300, transaction_id: 'transaction' )

    stub_create_report_job(report)
    stub_create_payment({
        customer: customer,
        amount:   Payment::SINGLE_REPORT_FEE
      }, Hashie::Mash.new(payment: payment))

    signin_customer(customer)
    put :update, report_id: report

    assert_redirected_to dashboard_path

    report = report.reload
    assert_equal payment, report.purchaseable
  end

  private

  def stub_create_payment(attrs, response)
    CreatePayment.expects(:call)
                 .with(attrs)
                 .returns(response)
  end
end
