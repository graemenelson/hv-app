class ApplicationController < ActionController::Base
  include CurrentVisitor
  include EventTracking

  # TODO: handle record not found, and other exceptions
  #       -- look at:  https://github.com/mirego/gaffe

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

end
