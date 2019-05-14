module Candidates
  class RegistrationsController < ApplicationController
    rescue_from Registrations::RegistrationSession::StepNotFound do |error|
      Rails.logger.warn "Step not found: #{error.inspect}"
      redirect_to public_send error.step_path
    end

  private

    def persist(model)
      current_registration.save model
    end

    def current_registration
      @current_registration ||= school_session.current_registration
    end

    def school_session
      @school_session ||= Registrations::SchoolSession.new current_urn, session
    end

    def current_urn
      params[:school_id]
    end

    def next_step_path(registration_session)
      step = registration_session.incomplete_steps.first
      send "new_candidates_school_registrations_#{step}_path"
    end
  end
end
