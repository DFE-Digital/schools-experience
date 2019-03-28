class Candidates::SchoolSearchesController < ApplicationController
  def new
    @search = Candidates::SchoolSearch.new(search_params)
  end

private

  def search_params
    params.permit(:location, :latitude, :longitude)
  end
end
