class PagesController < ApplicationController

  def landing
    # TODO: don't create visitors and track bots
    #       -- look at admin view that shows recent USER_AGENT and allow them to be added to the bot list
    #       -- allow them access to the page, but looking at blocking from other actions

    # what about a/b testing, can we use vanity with the events table?
    track! :landing, visitor: current_visitor
  end

end
