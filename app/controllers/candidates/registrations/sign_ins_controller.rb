module Candidates
  module Registrations
    class SignInsController < RegistrationsController
      include SignInEmails

      skip_before_action :ensure_step_permitted!, only: :update

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
        @personal_information.issue_verification_code

        redirect_to candidates_school_registrations_sign_in_path
      end

      def update
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

    private

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

      def attributes_from_session
        current_registration.personal_information_attributes
      end

      def verification_code_params
        params.require(:candidates_verification_code).permit(:code, :email, :firstname, :lastname, :date_of_birth)
      end
    end
  end
end
