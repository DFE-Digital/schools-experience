class CookiePreferencesController < ApplicationController
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
      redirect_to request.referer.presence || edit_cookie_preference_path
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
end
