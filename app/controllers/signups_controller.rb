class SignupsController < ApplicationController
  def information
    load_active_signup
    track_signup! :information
  end

  def update_information
    load_active_signup

    update_attrs = params.require(:signup)
                         .permit(:email, :timezone)
                         .merge( allow_blank_payment_method_nonce: true )

    if @signup.update_attributes(update_attrs)
      track_signup! :update_information
      redirect_to subscription_signup_path(@signup)
    else
      track_signup! :update_information_with_errors
      render :information
    end
  end

  def subscription
    load_active_signup

    # collect information before capturing the
    # subscription.
    if can_capture_subscription?(@signup)
      generate_braintree_client_token
    else
      unable_to_capture_subscription!
    end
  end

  def update_subscription
    load_active_signup

    if can_capture_subscription?(@signup)
      signup_attrs = params.require(:signup)
                           .permit(:payment_method_nonce,
                                   :payment_method_type,
                                   :terms_of_service)

      if @signup.update_attributes(signup_attrs)
        service = CustomerFromSignup.call(@signup)
        if customer = service.customer
          # TODO: need to create subscription default, $18 for 6 months
          #       -- keep in mind we might need to handle different plans later on
          update_session_with_customer(customer)
          track_signup! :completed
          redirect_to build_dashboard_path
        else
          @signup.errors.add(:base, "We ran into an issue with your payment: #{service.error.status.titleize}")
          unable_to_update_subscription!
        end

        # transaction = Braintree::Transaction.sale( {
        #   amount: '18.00',
        #   payment_method_nonce: @signup.payment_method_nonce,
        #   options: {
        #     submit_for_settlement: true,
        #     store_in_vault_on_success: true
        #   },
        #   customer: {
        #     id: @signup.instagram_id,
        #     email: @signup.email,
        #     website: "https://instagram.com/#{@signup.instagram_username}"
        #   }
        # })
        # response = Braintree::Customer.create({
        #     id: @signup.instagram_id,
        #     payment_method_nonce: @signup.payment_method_nonce,
        #     email: @signup.email,
        #     website: "http://instagram.com/#{@signup.instagram_username}"
        #   })
        #
        # puts response.inspect
        # try and capture Braintree::Transaction
      else
        unable_to_update_subscription!
      end
    else
      unable_to_capture_subscription!
    end
  end

  private

  def load_active_signup
    query   = {id: params[:id], completed_at: nil}
    @signup = Signup.where(query)
                    .first!
  end

  def unable_to_update_subscription!
    generate_braintree_client_token
    track_signup! :update_subscription_with_errors
    render :subscription
  end

  def can_capture_subscription?(signup)
    signup.email.present?
  end

  def track_signup!(name)
    track! "signup_#{name}",
                 visitor: current_visitor,
                 parameters: {
                   instagram_username: @signup.instagram_username,
                   instagram_id:       @signup.instagram_id,
                   errors:             @signup.errors.full_messages.join(", ")
                 }
  end

  def generate_braintree_client_token
    gon.braintree_client_token = Braintree::ClientToken.generate
  end

  def unable_to_capture_subscription!
    track_signup! :not_capturable
    redirect_to information_signup_path(@signup)
  end

end
