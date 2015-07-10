class PagesController < ApplicationController

  def landing
    Rails.logger.warn("   Session: #{session.id}")
  end

end
