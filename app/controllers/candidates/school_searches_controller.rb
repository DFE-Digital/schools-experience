class Candidates::SchoolSearchesController < ApplicationController
  include AnalyticsTracking

  def new
    @search = Candidates::SchoolSearch.new(search_params)
  end

private

  def search_params
    params.permit(:location, :age_group)
  end
end
