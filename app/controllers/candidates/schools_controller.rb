class Candidates::SchoolsController < ApplicationController
  EXPANDED_SEARCH_RADIUS = 50

  def index
    return redirect_to new_candidates_school_search_path unless location_present?

    @search = Candidates::SchoolSearch.new(search_params)

    return render 'candidates/school_searches/new' unless @search.valid?

    if @search.results.empty?
      @expanded_search_radius = true
      @search = Candidates::SchoolSearch.new(
        search_params.merge(distance: EXPANDED_SEARCH_RADIUS)
      )
    end
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
