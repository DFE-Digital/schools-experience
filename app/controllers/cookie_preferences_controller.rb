class CookiePreferencesController < ApplicationController
  before_action :load_existing_preference, except: :show

  def show
    redirect_to edit_cookie_preference_path
  end

  def edit; end

  def update
    @preference.assign_attributes preference_attributes

    if @preference.valid?
      persist @preference
      remove_rejected_cookies @preference
      redirect_to request.referer.presence || edit_cookie_preference_path
    else
      render 'edit'
    end
  end

private

  def load_existing_preference
    @preference = CookiePreference.from_cookie(cookies[cookie_key])
  end

  def preference_attributes
    params.fetch(:cookie_preference, {}).permit(:analytics, :all)
  end

  def persist(preferences)
    cookies[cookie_key] = {
      expires: preferences.expires,
      value: preferences.to_json,
      httponly: false,
    }
  end

  def cookie_key
    CookiePreference.cookie_key
  end

  def remove_rejected_cookies(preferences)
    preferences.rejected_cookies.each do |cookie_key|
      cookies.delete cookie_key
    end
  end
end
