module Candidates
  module Registrations
    class SignInsController < RegistrationsController
      include SignInEmails

      skip_before_action :ensure_step_permitted!, only: :update

      def show
        @email_address = current_registration.personal_information.email
        @resend_link = candidates_school_registrations_sign_in_path
      end

      def create
        @personal_information = current_registration.personal_information

        token = @personal_information.create_signin_token(gitis_crm)
        verification_email(token).despatch_later!

        redirect_to candidates_school_registrations_sign_in_path
      end

      def update
        candidate = Candidates::Session.signin!(params[:token])

        self.current_registration_session_uuid = params[:uuid]

        if candidate
          self.current_candidate = candidate

          # Update the registration data in redis with the candidate
          # information from gitis.
          personal_information = PersonalInformation.new attributes_from_session
          persist personal_information

          redirect_to new_candidates_school_registrations_contact_information_path
        elsif attributes_from_session.any?
          @resend_link = candidates_school_registrations_sign_in_path
        end
      end

    private

      def attributes_from_session
        current_registration.personal_information_attributes
      end
    end
  end
end
