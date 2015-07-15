class RegistrationsController < ApplicationController

  def show
    load_signup
    track_registration! :new
  end

  def update
    load_signup

    signup_attrs = params.require(:signup).permit(:email)
    if @signup.update_attributes(signup_attrs)
      customer = CustomerFromSignup.call(@signup).customer
      update_session_with_customer customer
      track_registration! :completed
      redirect_to payment_path
    else
      handle_new_with_errors
    end

  end

  private

  def handle_new_with_errors
    track_registration! :new_with_errors
    render :show
  end

  def load_signup
    @signup = Signup.find(params[:id])
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
