class SignupsController < ApplicationController
  def information
    load_signup
    track_signup! :information
  end

  def update_information
    load_signup

    update_attrs = params.require(:signup)
                         .permit(:email)
                         .merge( allow_blank_payment_method_nonce: true )

    if @signup.update_attributes(update_attrs)
      track_signup! :update_information
      redirect_to subscription_signup_path(@signup)
    else
      track_signup! :update_information_with_errors
      render :information
    end
  end
  private

  def load_signup
    @signup = Signup.find(params[:id])
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

end
