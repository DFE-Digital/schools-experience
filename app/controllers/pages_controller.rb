class PagesController < ApplicationController
  def show
    render template: sanitise_page
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
