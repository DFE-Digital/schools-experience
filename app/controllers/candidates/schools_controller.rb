class Candidates::SchoolsController < ApplicationController
  include AnalyticsTracking
  EXPANDED_SEARCH_RADIUS = 50

  content_security_policy(only: :show) do |policy| # Allow bing maps
    policy.connect_src :self, 'https://www.bing.com', "https://*.visualstudio.com"
    policy.font_src :self, :data
    policy.img_src :self, :data, 'https://www.bing.com', 'https://*.virtualearth.net', "https://www.google-analytics.com"
    policy.style_src :self, "'unsafe-inline'", 'https://www.bing.com'
    policy.script_src :self, :data, "'unsafe-inline'",
      "'unsafe-eval'",
      'https://www.bing.com',
      'https://*.virtualearth.net',
      "https://www.googletagmanager.com",
      "https://www.google-analytics.com",
      "https://*.vo.msecnd.net"
  end

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
    if @school.private_beta?
      @presenter = Candidates::SchoolPresenter.new(@school, @school.profile)
    end
    @available_dates = @school.bookings_placement_dates.available
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
end
