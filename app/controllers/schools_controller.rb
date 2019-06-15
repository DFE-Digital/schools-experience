class SchoolsController < ApplicationController
  include DFEAuthentication

  before_action :redirect_to_dashboard, if: :user_signed_in?

  def show; end

private

  def redirect_to_dashboard
    redirect_to(schools_dashboard_path)
  end
end
