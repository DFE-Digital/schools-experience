class CookiePreferencesController < ApplicationController
  before_action :load_existing_preference, except: :show

  def show
    redirect_to edit_cookie_preference_path
  end

  def edit; end

  def update
    @preference.assign_attributes preference_attributes

    if @preference.valid?
      redirect_to edit_cookie_preference_path
    else
      render 'edit'
    end
  end

private

  def load_existing_preference
    @preference = CookiePreference.new
  end

  def preference_attributes
    params.fetch(:cookie_preference, {}).permit(:analytics)
  end
end
