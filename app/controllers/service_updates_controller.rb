class ServiceUpdatesController < ApplicationController
  def index
    @recent_updates = ServiceUpdate.latest(6)
    @latest = @recent_updates.shift
    set_viewed_cookie @latest
  end

  def show
    @update = ServiceUpdate.from_param(params[:id])
    set_viewed_cookie @update
  end

private

  def set_viewed_cookie(update)
    return if viewed_cookie && viewed_cookie >= update.to_param

    cookies[ServiceUpdate.cookie_key] = {
      expires: CookiePreference::EXPIRES_IN.from_now,
      value: update.to_param,
      httponly: true
    }
  end

  def viewed_cookie
    cookies[ServiceUpdate.cookie_key]
  end
end
