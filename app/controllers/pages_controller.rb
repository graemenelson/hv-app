class PagesController < ApplicationController

  def landing
    # what about a/b testing, can we use vanity with the events table?
    track! :landing, visitor: current_visitor
  end

end
