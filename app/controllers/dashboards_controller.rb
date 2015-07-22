class DashboardsController < ApplicationController

  before_filter :ensure_customer!
  before_filter :ensure_profile_created!, only: :show

  def build
    redirect_to dashboard_path if profile_created?
  end

  def show
    @dashboard = DashboardPresenter.new(current_customer)
  end

  private

  def profile_created?
    current_customer.profile_created_at.present?
  end

  def ensure_profile_created!
    redirect_to build_dashboard_path and return false unless profile_created?
  end

end
