class CookiePreferencesController < ApplicationController
  def show
    redirect_to edit_cookie_preference_path
  end
end
