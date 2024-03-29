class Candidates::SchoolsController < ApplicationController
  include MapsContentSecurityPolicy
  EXPANDED_SEARCH_RADIUS = 50

  before_action :redirect_if_deactivated

  def create
    encrypted_params = Candidates::SchoolSearch.new(search_params).encrypted_attributes
    redirect_to(candidates_schools_path(encrypted_params))
  end

  def index
    @search = Candidates::SchoolSearch.new_decrypt(search_params)
    render 'candidates/school_searches/new' and return unless @search.valid? && location_present?

    @facet_tags = FacetTagsPresenter.new(@search.applied_filters)

    @country = @search.country

    if @search.results.empty? && !@search.whitelisted_urns?
      @expanded_search_radius = true
      @search = Candidates::SchoolSearch.new_decrypt(search_params.merge(distance: EXPANDED_SEARCH_RADIUS))
    end
  end

  def show
    @school = Candidates::School.find(params[:id])

    unless school_in_whitelist? @school
      return redirect_to candidates_root_path
    end

    add_x_robots_tag(set_to_all: @school.enabled)

    @school.increment!(:views)

    if @school.onboarded?
      @presenter = Candidates::SchoolPresenter.new(@school, @school.profile)
    else
      @available_dates = @school.bookings_placement_dates.available
    end
  end

private

  def location_present?
    search_params[:location].present? || (
      search_params[:longitude].present? && search_params[:latitude].present?
    )
  end

  def search_params
    params.permit(
      :query, :location, :latitude, :longitude, :page, :distance, :disability_confident,
      :max_fee, :parking, phases: [], subjects: [], dbs_policies: []
    )
  end

  def redirect_if_deactivated
    if Rails.application.config.x.candidates.deactivate_applications
      redirect_to candidates_root_path
    end
  end

  def school_in_whitelist?(school)
    !Bookings::SchoolSearch.whitelisted_urns? ||
      Bookings::SchoolSearch.whitelisted_urns.include?(school.urn)
  end
end
