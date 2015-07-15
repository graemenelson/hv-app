class InstagramController < ApplicationController

  def connect
    track! :connect, visitor: current_visitor
    redirect_to Instagram.authorize_url(redirect_uri: auth_instagram_callback_url)
  end

  def callback
    response = Instagram.get_access_token(params[:code], redirect_uri: auth_instagram_callback_url)
    # strategy = InstagramSigninStrategy.new(response)
    # send("#{strategy.name}", strategy)

    # if we have a customer based on instagram id in the response, load and redirect to dashboard
    # if we have a signup based on instagram id, load and redirect to register
    # if we don't have a signup based on instagram id, create one and redirect to register
    # otherwise handle errors
    if customer = Customer.find_by_instagram_id(response.user.id)
      update_session_with_customer(customer)
      # TODO: track login -- most likely track on dashboard page
      redirect_to dashboard_path
    else
      signup = create_or_update_signup(response)
      redirect_to information_signup_path(signup)
    end
  end

  private

  def create_or_update_signup(response)
    if signup = Signup.find_by_instagram_id(response.user.id)
      signup.update_attributes(
        instagram_username: response.user.username,
        access_token: response.access_token,
        instagram_profile_picture: response.user.profile_picture,
        allow_blank_email: true,
        allow_blank_payment_method_nonce: true
      )
      signup
    else
      Signup.create(
        instagram_id: response.user.id,
        instagram_username: response.user.username,
        access_token: response.access_token,
        instagram_profile_picture: response.user.profile_picture
      )
    end
  end

end
