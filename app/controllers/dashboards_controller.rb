class DashboardsController < ApplicationController

  before_filter :ensure_customer!

  def build
    # TODO: checks to see if we are done, delay for at least XX seconds
  end

end
