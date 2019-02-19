module Candidates
  module Registrations
    class ResendConfirmationEmailsController < RegistrationsController
      def create
        uuid = params[:uuid]

        if RegistrationStore.instance.has_registration? uuid
          SendEmailConfirmationJob.perform_later uuid

          redirect_to candidates_school_registrations_confirmation_email_path \
            email: params[:email],
            school_name: params[:school_name],
            uuid: uuid
        else
          render :session_expired
        end
      end
    end
  end
end
