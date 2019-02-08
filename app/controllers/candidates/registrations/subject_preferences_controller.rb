module Candidates
  module Registrations
    class SubjectPreferencesController < RegistrationsController
      def new
        @subject_preference = SubjectPreference.new urn: current_urn
      end

      def create
        @subject_preference = SubjectPreference.new \
          subject_preference_params.merge(urn: current_urn)

        if @subject_preference.valid?
          persist @subject_preference
          redirect_to new_candidates_school_registrations_background_check_path
        else
          render :new
        end
      end

      def edit
        @subject_preference = current_registration.subject_preference
      end

      def update
        @subject_preference = current_registration.subject_preference
        @subject_preference.assign_attributes subject_preference_params

        if @subject_preference.valid?
          persist @subject_preference
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def subject_preference_params
        params.require(:candidates_registrations_subject_preference).permit \
          :degree_stage,
          :degree_stage_explaination,
          :degree_subject,
          :teaching_stage,
          :subject_first_choice,
          :subject_second_choice
      end
    end
  end
end
