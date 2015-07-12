class RegistrationsController < ApplicationController

  def show
    load_signup
    track_registration! :new
    generate_braintree_client_token
  end

  def update_signup_with_email_and_billing_info
    signup_params = params.require(:signup).permit(:email, :payment_method_nonce)

    # if we have a root level :payment_method_nonce,
    # that means it's from Braintree, so use that value.
    if params.key?(:payment_method_nonce)
      signup_params.merge!(payment_method_nonce: params[:payment_method_nonce])
    end

    @signup.update_attributes(signup_params)
  end

  def update
    load_signup
    update_signup_with_email_and_billing_info

    if @signup.captured_email_and_billing_info?
      service = CustomerFromSignup.call(@signup)
      if service.customer
        current_customer(service.customer)
        # TODO: send welcome email to customer
        redirect_to dashboard_path
      else
        # TODO: log error to help track down payment issues
        @signup.errors.add(:base, "We ran into an issue with your payment: #{service.error.status.titleize}")
        handle_new_with_errors(generate_braintree_client_token: true)
      end
    else
      handle_new_with_errors(generate_braintree_client_token: @signup.payment_method_nonce.blank?)
    end

  end

  private

  def handle_new_with_errors(options = {})
    generate_braintree_client_token if options[:generate_braintree_client_token]
    track_registration! :new_with_errors
    render :show
  end

  def load_signup
    @signup = Signup.find(params[:id])
  end

  def generate_braintree_client_token
    gon.braintree_client_token = Braintree::ClientToken.generate
  end

  def track_registration!(name)
    track! "registration_#{name}",
                 visitor: current_visitor,
                 parameters: {
                   instagram_username: @signup.instagram_username,
                   instagram_id:       @signup.instagram_id,
                   errors:             @signup.errors.full_messages.join(", ")
                 }
  end
end
