class Candidates::SchoolsController < ApplicationController
  def index
    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    @school = Candidates::School.find(params[:id])
  end

private

  def search_params
    params.permit(
      :query, :location, :latitude, :longitude, :page,
      :distance, :max_fee, :order, phases: [], subjects: []
    )
  end
end
