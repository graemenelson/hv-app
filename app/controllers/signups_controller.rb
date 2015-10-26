class SignupsController < ApplicationController

  layout "signup"

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
      load_default_plan
    else
      unable_to_capture_subscription!
    end
  end

  def update_subscription
    load_active_signup

    if can_capture_subscription?(@signup)
      signup_attrs = params.require(:signup)
                           .permit(:payment_method_nonce,
                                   :payment_method_type)
      plan = load_default_plan
      if @signup.update_attributes(signup_attrs.merge(plan: plan))
        if customer = create_customer_from_signup
          update_session_with_customer(customer)
          track_signup! :completed
          BuildCustomerProfileJob.perform_later customer
          redirect_to build_dashboard_path
        else
          unable_to_update_subscription!
        end

      else
        unable_to_update_subscription!
      end
    else
      unable_to_capture_subscription!
    end
  end

  private

  def create_customer_from_signup
    service = CustomerFromSignup.call(@signup)
    unless customer = service.customer
      @signup.errors.add(:base, "We ran into an issue with your payment: #{service.error.titleize}")
    end
    customer
  end

  def load_active_signup
    query   = {id: params[:id], completed_at: nil}
    @signup = Signup.where(query)
                    .first!
  end

  def load_default_plan
    @plan = Plan.default
  end

  def unable_to_update_subscription!
    generate_braintree_client_token
    load_default_plan
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
