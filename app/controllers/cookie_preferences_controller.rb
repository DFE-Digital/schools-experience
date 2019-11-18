class CookiePreferencesController < ApplicationController
  before_action :load_existing_preference, except: :show

  def show
    redirect_to edit_cookie_preference_path
  end

  def edit; end

  def update
    render 'edit'
  end

private

  def load_existing_preference
    @preference = CookiePreference.new
  end
end
