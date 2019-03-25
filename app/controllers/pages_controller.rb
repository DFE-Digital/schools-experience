class PagesController < ApplicationController
  def show
    render template: sanitise_page
  end

  def healthcheck
    render plain: 'healthy'
  end

  def privacy_policy; end

  def cookies_policy; end

  def migration; end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    when 'privacy_policy' then 'pages/privacy_policy'
    when 'cookies_policy' then 'pages/cookies_policy'
    when 'migration' then 'pages/migration'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
