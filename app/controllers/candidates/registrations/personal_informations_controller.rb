module Candidates
  module Registrations
    class PersonalInformationsController < RegistrationsController
      def new
        @personal_information = PersonalInformation.new attributes_from_session
      end

      def create
        @personal_information = PersonalInformation.new personal_information_params
        if @personal_information.valid?
          persist @personal_information

          if candidate_signed_in?
            redirect_to new_candidates_school_registrations_contact_information_path
          else
            token = @personal_information.create_signin_token(gitis_crm)

            if token
              verification_email(token).despatch_later!
              redirect_to candidates_school_registrations_sign_ins_path
            else
              redirect_to new_candidates_school_registrations_contact_information_path
            end
          end
        else
          render :new
        end
      end

      def edit
        @personal_information = current_registration.personal_information
      end

      def update
        @personal_information = current_registration.personal_information
        @personal_information.assign_attributes personal_information_params

        if @personal_information.valid?
          persist @personal_information
          # FIXME need to consider scenario where the user swaps out email address after confirming
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def personal_information_params
        params.require(:candidates_registrations_personal_information).permit \
          :first_name,
          :last_name,
          :email
      end

      def attributes_from_session
        current_registration.personal_information_attributes.except 'created_at'
      end

      def verification_email(token)
        NotifyEmail::CandidateVerifyEmailLink.new(
          to: current_registration.personal_information.email,
          verification_link: verification_link(token)
        )
      end

      def verification_link(token)
        candidates_school_registrations_sign_in_url \
          current_registration.urn,
          token,
          host: request.host
      end
    end
  end
end
