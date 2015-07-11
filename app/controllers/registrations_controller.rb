class RegistrationsController < ApplicationController
  def show
    @signup = Signup.find(params[:id])
    track! :register, visitor: current_visitor,
                      parameters: {
                        instagram_username: @signup.instagram_username,
                        instagram_id:       @signup.instagram_id
                      }
  end
end
