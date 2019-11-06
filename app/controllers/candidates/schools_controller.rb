class Candidates::SchoolsController < ApplicationController
  include AnalyticsTracking
  include BingMapsContentSecurityPolicy
  EXPANDED_SEARCH_RADIUS = 50

  def index
    return redirect_to new_candidates_school_search_path unless location_present?

    @search = Candidates::SchoolSearch.new(search_params_with_analytics_tracking)

    return render 'candidates/school_searches/new' unless @search.valid?

    if @search.results.empty?
      @expanded_search_radius = true
      @search = Candidates::SchoolSearch.new(
        search_params_with_analytics_tracking.merge(distance: EXPANDED_SEARCH_RADIUS)
      )
    end
  end

  def show
    @school = Candidates::School.find(params[:id])
    @school.increment!(:views)

    if @school.private_beta?
      @presenter = Candidates::SchoolPresenter.new(@school, @school.profile)
    else
      @available_dates = @school.bookings_placement_dates.available
    end
  end

private

  def location_present?
    search_params[:location].present?
  end

  def search_params
    params.permit(
      :query, :location, :page, :distance, :max_fee, :order, :age_group,
      phases: [], subjects: []
    )
  end

  def search_params_with_analytics_tracking
    search_params.merge(analytics_tracking_uuid: cookies[:analytics_tracking_uuid])
  end
end
