class PagesController < ApplicationController
  def show
    render template: sanitise_page
  end

  def privacy_policy
    @policy_id = Bookings::Gitis::PrivacyPolicy.default
  end

  def schools_privacy_policy; end

  def cookies_policy; end

  def migration; end

  def service_update; end

  def help_and_support_access_needs; end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    when 'privacy_policy' then 'pages/privacy_policy'
    when 'schools_privacy_policy' then 'pages/schools_privacy_policy'
    when 'cookies_policy' then 'pages/cookies_policy'
    when 'migration' then 'pages/migration'
    when 'service_update' then 'pages/service_update'
    when 'help_and_support_access_needs' then 'pages/help_and_support_access_needs'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
