class Candidates::SchoolsController < ApplicationController
  def index
    redirect_to new_candidates_school_search_path unless location_present?

    @search = Candidates::SchoolSearch.new(search_params)
  end

  def show
    @school = Candidates::School.find(params[:id])
  end

private

  def location_present?
    search_params[:location].present? || (
      search_params[:latitude].present? && search_params[:latitude].present?
    )
  end

  def search_params
    params.permit(
      :query, :location, :latitude, :longitude, :page,
      :distance, :max_fee, :order, phases: [], subjects: []
    )
  end
end
