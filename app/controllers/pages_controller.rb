class PagesController < ApplicationController
  def show
    render template: sanitise_page
  end

  def healthcheck
    render plain: 'healthy'
  end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    when 'privacy_policy' then 'pages/privacy_policy'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
