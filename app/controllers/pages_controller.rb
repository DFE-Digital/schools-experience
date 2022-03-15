class PagesController < ApplicationController
  before_action :set_manage_site_header
  before_action :set_enabled_schools_urns, only: %i[robots sitemap]

  def show
    render template: sanitise_page
  end

  def privacy_policy
    @privacy_policy = GetIntoTeachingApiClient::PrivacyPoliciesApi.new.get_latest_privacy_policy.text
  end

  def schools_privacy_policy; end

  def cookies_policy; end

  def migration; end

  def service_update; end

  def help_and_support_access_needs; end

  def schools_request_organisation
    @dfe_sign_in_add_service_url =
      Rails.application.config.x.dfe_sign_in_add_service_url.presence
  end

  def maintenance
    render status: :service_unavailable
  end

  def robots
    render("robots", formats: :txt, layout: false)
  end

  def sitemap; end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    when 'privacy_policy' then 'pages/privacy_policy'
    when 'schools_privacy_policy' then 'pages/schools_privacy_policy'
    when 'schools_request_organisation' then 'pages/schools_request_organisation'
    when 'cookies_policy' then 'pages/cookies_policy'
    when 'migration' then 'pages/migration'
    when 'help_and_support_access_needs' then 'pages/help_and_support_access_needs'
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def set_manage_site_header
    if request.path.start_with? '/schools/'
      @site_header_text = "Manage school experience"
    end
  end

  def set_enabled_schools_urns
    @enabled_schools_urns = Bookings::School.enabled.pluck(:urn)
  end
end
