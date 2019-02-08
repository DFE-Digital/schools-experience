module Candidates
  class RegistrationsController < ApplicationController
  private

    def persist(model)
      current_registration.save model
    end

    def current_registration
      @current_registration ||= Registrations::RegistrationSession.new(session)
    end

    def current_urn
      params[:school_id]
    end
  end
end
