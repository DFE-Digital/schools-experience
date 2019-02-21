module Candidates
  module Registrations
    class ConfirmationEmailsController < RegistrationsController
      def show
        @email = params[:email]
        @school_name = params[:school_name]
        @resend_path = candidates_school_registrations_resend_confirmation_email_path \
          email: @email,
          school_name: @school_name,
          uuid: params[:uuid]
      end

      def create
        uuid = RegistrationStore.instance.store! current_registration

        SendEmailConfirmationJob.perform_later uuid

        redirect_to candidates_school_registrations_confirmation_email_path \
          email: current_registration.email,
          school_name: current_registration.school.name,
          uuid: uuid
      end
    end
  end
end
