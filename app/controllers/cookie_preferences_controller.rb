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
      redirect_to edit_cookie_preference_path
    else
      render 'edit'
    end
  end

private

  def load_existing_preference
    @preference = CookiePreference.from_cookie(cookies[cookie_key])
  end

  def preference_attributes
    params.fetch(:cookie_preference, {}).permit(:analytics)
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
end
