module Candidates
  module Registrations
    class PersonalInformationsController < RegistrationsController
      include SignInEmails

      def new
        @personal_information = PersonalInformation.new attributes_from_session
      end

      def create
        @personal_information = PersonalInformation.new attributes_from_session
        @personal_information.attributes = personal_information_params

        render(:new) && return unless @personal_information.valid?

        persist @personal_information

        if candidate_signed_in?
          redirect_to new_candidates_school_registrations_contact_information_path
        else
          perform_matchback
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

          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def perform_matchback
        success = @personal_information.issue_verification_code

        if success
          redirect_to candidates_school_registrations_sign_in_path
        else
          redirect_to new_candidates_school_registrations_contact_information_path
        end
      end

      def personal_information_params
        if candidate_signed_in?
          params.fetch(:candidates_registrations_personal_information, {}).permit \
            :first_name,
            :last_name
        else
          params.fetch(:candidates_registrations_personal_information, {}).permit \
            :first_name,
            :last_name,
            :email
        end
      end

      def attributes_from_session
        current_registration.personal_information_attributes.except 'created_at'
      end
    end
  end
end
