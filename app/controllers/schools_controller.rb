class SchoolsController < ApplicationController
  before_action :redirect_to_dashboard,
    if: -> { session[:current_user].present? }

  def show; end

private

  def redirect_to_dashboard
    redirect_to(schools_dashboard_path)
  end
end
