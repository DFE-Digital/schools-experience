module Candidates
  class RegistrationsController < ApplicationController
    include Registrations::CurrentRegistration
    include Registrations::Wizard
    include GitisAuthentication

    rescue_from Registrations::RegistrationSession::StepNotFound do |error|
      Rails.logger.warn "Step not found: #{error.inspect}"
      redirect_to next_step_path
    end

    helper_method :candidate_signed_in?

  private

    def gitis_mapper(registration_session = current_registration,
                     gitis_contact = current_contact)

      Bookings::RegistrationContactMapper.new(registration_session, gitis_contact)
    end
  end
end
