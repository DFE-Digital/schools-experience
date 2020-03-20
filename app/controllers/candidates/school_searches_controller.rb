class Candidates::SchoolSearchesController < ApplicationController
  include AnalyticsTracking
  before_action :redirect_if_deactivated

  def new
    @search = Candidates::SchoolSearch.new(search_params)
  end

private

  def search_params
    params.permit(:location, :latitude, :longitude)
  end

  def redirect_if_deactivated
    if Rails.application.config.x.candidates.deactivate_applications
      redirect_to candidates_root_path
    end
  end
end
