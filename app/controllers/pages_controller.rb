class PagesController < ApplicationController
  def show
    render template: sanitise_page
  end

  def healthcheck
    render plain: 'healthy'
  end

  def privacy_policy; end

  def cookies_policy; end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
