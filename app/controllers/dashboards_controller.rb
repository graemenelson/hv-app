class DashboardsController < ApplicationController

  before_filter :ensure_customer!

  def build
    redirect_to dashboard_path if profile_created?
  end

  def show
    redirect_to build_dashboard_path unless profile_created?
  end

  private

  def profile_created?
    current_customer.profile_created_at.present?
  end

end
