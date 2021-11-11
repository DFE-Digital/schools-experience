class CookiePreferencesController < ApplicationController
  REFERER_BLACKLIST = %r{/(cookie_preference)}.freeze
  skip_before_action :verify_authenticity_token, only: %i[update]
  before_action :save_referer

  def show
    redirect_to edit_cookie_preference_path
  end

  def edit; end

  def update
    cookie_preferences.assign_attributes preference_attributes

    if cookie_preferences.valid?
      persist cookie_preferences
      # TEMP: debugging cookies not removed in prod
      Rails.logger.info("CookiePreferencesController#update before removing cookies:#{cookies.inspect}")
      remove_rejected_cookies cookie_preferences
      # TEMP: debugging cookies not removed in prod
      Rails.logger.info("CookiePreferencesController#update after removing cookies:#{cookies.inspect}")
      flash[:cookies] = 'updated'
      redirect_to return_url
    else
      render 'edit'
    end
  end

private

  def preference_attributes
    params.fetch(:cookie_preference, {}).permit(:analytics, :all)
  end

  def persist(preferences)
    cookies[CookiePreference.cookie_key] = {
      expires: preferences.expires,
      value: preferences.to_json,
      httponly: false
    }
  end

  def remove_rejected_cookies(preferences)
    # TEMP: debugging cookies not removed in prod
    Rails.logger.info("CookiePreferencesController#remove_rejected_cookies with preferences: #{preferences} from #{cookies.inspect}")
    preferences.rejected_cookies.each do |cookie_key|
      # TEMP: debugging cookies not removed in prod
      Rails.logger.info("CookiePreferencesController#remove_rejected_cookies delete: #{cookie_key}")
      cookies.delete cookie_key
    end
  end

  def save_referer
    session[:cookie_preference_referer] =
      if non_get_referer?
        root_url
      elsif request.referer.present? && request.referer !~ REFERER_BLACKLIST
        request.referer
      end
  end

  def non_get_referer?
    Rails.application.routes.recognize_path(request.referer).blank?
  rescue ActionController::RoutingError
    true
  end

  def return_url
    session.delete(:cookie_preference_referer).presence ||
      edit_cookie_preference_path
  end
end
