module Candidates
  module Registrations
    class ResendConfirmationEmailsController < RegistrationsController
      def create
        registration_session = RegistrationStore.instance.retrieve! current_registration.uuid

        if registration_session.pending_email_confirmation?
          SendEmailConfirmationJob.perform_later \
            registration_session.uuid,
            request.host

          redirect_to candidates_school_registrations_confirmation_email_path
        else
          render 'shared/session_expired'
        end
      rescue RegistrationStore::SessionNotFound => e
        ExceptionNotifier.notify_exception(e, data: {
          action: 'ResendConfirmationEmailsController#create',
          uuid: current_registration.uuid
        })

        Raven.capture_exception(e)

        render 'shared/session_expired'
      end
    end
  end
end
