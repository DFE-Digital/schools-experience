class PagesController < ApplicationController
  def show
    render template: sanitise_page
  end

  def healthcheck
    render plain: 'healthy'
  end

  # FIXME this page should be removed
  def fivehundred
    raise "Test Exception Handler"
  end

private

  def sanitise_page
    case params[:page]
    when 'home' then 'pages/home'
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
