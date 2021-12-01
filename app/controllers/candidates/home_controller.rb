class Candidates::HomeController < ApplicationController
  def index
    @applications_deactivated = \
      Rails.application.config.x.candidates.deactivate_applications
  end

  def guide_for_candidates; end
end
