module Candidates
  module Registrations
    class SignInsController < RegistrationsController
      include SignInEmails

      skip_before_action :ensure_step_permitted!, only: :update
      before_action :check_api_feature_enabled, only: %i[show update create]

      def show
        set_sign_in_details
        @verification_code = Candidates::VerificationCode.new({
          email: current_registration.personal_information.email,
          firstname: current_registration.personal_information.first_name,
          lastname: current_registration.personal_information.last_name,
          date_of_birth: current_registration.personal_information.date_of_birth,
        })
      end

      def create
        @personal_information = current_registration.personal_information

        if @git_api_enabled
          @personal_information.issue_verification_code
        else
          token = @personal_information.create_signin_token(gitis_crm)
          verification_email(token).despatch_later!
        end

        redirect_to candidates_school_registrations_sign_in_path
      end

      def update
        @git_api_enabled ? api_verify : direct_verify
      end

    private

      def api_verify
        @verification_code = Candidates::VerificationCode.new(verification_code_params)
        candidate_data = @verification_code.exchange

        if candidate_data
          self.current_candidate = Bookings::Candidate.find_or_create_from_gitis_contact!(candidate_data).tap do |c|
            c.update(confirmed_at: Time.zone.now)
          end
          update_registration_data
          redirect_to new_candidates_school_registrations_contact_information_path
        else
          set_sign_in_details
          render :show
        end
      end

      def direct_verify
        candidate = Candidates::Session.signin!(params[:token])

        self.current_registration_session_uuid = params[:uuid]

        if candidate
          self.current_candidate = candidate
          update_registration_data
          redirect_to new_candidates_school_registrations_contact_information_path
        elsif attributes_from_session.any?
          @resend_link = candidates_school_registrations_sign_in_path
        end
      end

      def update_registration_data
        # Update the registration data in redis with the candidate
        # information from gitis.
        personal_information = PersonalInformation.new attributes_from_session
        persist personal_information
      end

      def set_sign_in_details
        @email_address = current_registration.personal_information.email
        @resend_link = candidates_school_registrations_sign_in_path
      end

      def check_api_feature_enabled
        @git_api_enabled = Flipper.enabled?(:git_api)
      end

      def attributes_from_session
        current_registration.personal_information_attributes
      end

      def verification_code_params
        params.require(:candidates_verification_code).permit(:code, :email, :firstname, :lastname, :date_of_birth)
      end
    end
  end
end
