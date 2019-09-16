module Candidates
  class RegistrationsController < ApplicationController
    include GitisAuthentication
    include Registrations::Wizard

    rescue_from Registrations::RegistrationSession::StepNotFound do |error|
      Rails.logger.warn "Step not found: #{error.inspect}"
      redirect_to next_step_path
    end

    helper_method :candidate_signed_in?

  private

    def persist(model)
      current_registration.save model
    end

    def current_registration
      @current_registration ||= school_session.current_registration(current_contact)
    end

    def school_session
      @school_session ||= Registrations::SchoolSession.new current_urn, session
    end

    def current_urn
      params[:school_id]
    end

    def gitis_mapper(registration_session = current_registration,
        gitis_contact = self.current_contact)

      Bookings::RegistrationContactMapper.new(registration_session, gitis_contact)
    end
  end
end
