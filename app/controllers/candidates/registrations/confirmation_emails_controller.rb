module Candidates
  module Registrations
    class ConfirmationEmailsController < RegistrationsController
      def show
        @email = current_registration.email
        @school_name = current_registration.school.name
        @resend_path = candidates_school_registrations_resend_confirmation_email_path
      end

      def create
        @privacy_policy = PrivacyPolicy.new privacy_policy_params

        if @privacy_policy.accepted?
          current_registration.flag_as_pending_email_confirmation!

          RegistrationStore.instance.store! current_registration

          SendEmailConfirmationJob.perform_later \
            current_registration.uuid,
            request.host

          redirect_to candidates_school_registrations_confirmation_email_path
        else
          @application_preview = ApplicationPreview.new current_registration
          render 'candidates/registrations/application_previews/show'
        end

        rescue RegistrationSession::NotCompletedError
          redirect_to candidates_school_registrations_application_preview_path
      end

    private

      def privacy_policy_params
        params.require(:candidates_registrations_privacy_policy).permit \
          :acceptance
      end
    end
  end
end
