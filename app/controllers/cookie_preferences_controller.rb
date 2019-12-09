class CookiePreferencesController < ApplicationController
  REFERER_BLACKLIST = %r{/(cookie_preference|cookies_policy)}.freeze
  before_action :save_refererer

  def show
    redirect_to edit_cookie_preference_path
  end

  def edit; end

  def update
    cookie_preferences.assign_attributes preference_attributes

    if cookie_preferences.valid?
      persist cookie_preferences
      remove_rejected_cookies cookie_preferences
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
      httponly: false,
    }
  end

  def remove_rejected_cookies(preferences)
    preferences.rejected_cookies.each do |cookie_key|
      cookies.delete cookie_key
    end
  end

  def save_refererer
    if request.referer.present? && request.referer !~ REFERER_BLACKLIST
      session[:cookie_preference_referer] = request.referer
    end
  end

  def return_url
    session.delete(:cookie_preference_referer).presence ||
      edit_cookie_preference_path
  end
end
