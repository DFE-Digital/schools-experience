module Candidates
  module Registrations
    class ResendConfirmationEmailsController < RegistrationsController
      def create
        if current_registration.pending_email_confirmation?
          SendEmailConfirmationJob.perform_later \
            current_registration.uuid,
            request.host

          redirect_to candidates_school_registrations_confirmation_email_path
        else
          render :session_expired
        end
      end
    end
  end
end
