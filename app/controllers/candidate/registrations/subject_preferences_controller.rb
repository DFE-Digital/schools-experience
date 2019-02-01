module Candidate
  module Registrations
    class SubjectPreferencesController < RegistrationsController
      def new
        @subject_preference = SubjectPreference.new
      end

      def create
        @subject_preference = SubjectPreference.new subject_preference_params
        if @subject_preference.valid?
          current_registration[:subject_preference] = @subject_preference.attributes
          redirect_to new_candidate_registrations_background_check_path
        else
          render :new
        end
      end

    private

      def subject_preference_params
        params.require(:candidate_registrations_subject_preference).permit \
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
