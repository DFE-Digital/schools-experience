class Candidates::SchoolsController < ApplicationController
  include AnalyticsTracking
  include BingMapsContentSecurityPolicy
  EXPANDED_SEARCH_RADIUS = 50

  before_action :redirect_if_deactivated

  def index
    return redirect_to new_candidates_school_search_path unless location_present?

    @search = Candidates::SchoolSearch.new(search_params_with_analytics_tracking)

    return render 'candidates/school_searches/new' unless @search.valid?

    if @search.results.empty? && !@search.whitelisted_urns?
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

  def search_params_with_analytics_tracking
    search_params.merge(analytics_tracking_uuid: cookies[:analytics_tracking_uuid])
  end

  def redirect_if_deactivated
    if Rails.application.config.x.candidates.deactivate_applications
      redirect_to candidates_root_path
    end
  end
end
