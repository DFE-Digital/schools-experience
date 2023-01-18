module Candidates
  module Registrations
    class ConfirmationEmailsController < RegistrationsController
      invisible_captcha only: [:create], timestamp_threshold: 1.second

      def show
        @email = current_registration.email
        @school_name = current_registration.school.name
        @resend_link = candidates_school_registrations_resend_confirmation_email_path
      end

      def create
        sign_in_candidate if !candidate_signed_in? && Feature.enabled?(:skip_candidate_confirmation_emails)

        if candidate_signed_in?
          RegistrationStore.instance.store! current_registration
          redirect_to candidates_confirm_path uuid: current_registration.uuid
        else
          send_confirmation_email
        end
      rescue RegistrationSession::NotCompletedError
        # We can get here if the school changes their date format while the
        # candidate is applying, or we push a code change mid way through a
        # registration.
        redirect_to next_step_path(current_registration)
      end

    private

      def sign_in_candidate
        self.current_candidate = Bookings::Candidate.create_or_update_from_registration_session! \
          current_registration,
          current_contact
      end

      def send_confirmation_email
        current_registration.flag_as_pending_email_confirmation!
        RegistrationStore.instance.store! current_registration

        SendEmailConfirmationJob.perform_later \
          current_registration.uuid,
          request.host

        redirect_to candidates_school_registrations_confirmation_email_path
      end
    end
  end
end
