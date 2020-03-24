class Candidates::HomeController < ApplicationController
  def index
    @applications_deactivated = \
      Rails.application.config.x.candidates.deactivate_applications

    @candidate_application_notification = ENV['CANDIDATE_NOTIFICATION'].presence
  end
end
