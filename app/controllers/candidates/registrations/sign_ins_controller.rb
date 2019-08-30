module Candidates
  module Registrations
    class SignInsController < RegistrationsController
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

        if candidate
          self.current_candidate = candidate

          redirect_to new_candidates_school_registrations_contact_information_path
        else
          @resend_link = candidates_school_registrations_sign_in_path
        end
      end

    private

      def verification_email(token)
        NotifyEmail::CandidateVerifyEmailLink.new(
          to: current_registration.personal_information.email,
          verification_link: verification_link(token)
        )
      end

      def verification_link(token)
        candidates_registration_verify_url \
          current_registration.urn,
          token,
          host: request.host
      end
    end
  end
end
