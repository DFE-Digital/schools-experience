class Candidates::HomeController < ApplicationController
  def index
    @applications_deactivated = \
      Rails.application.config.x.candidates.deactivate_applications
  end
end
