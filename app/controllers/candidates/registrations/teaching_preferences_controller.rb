module Candidates
  module Registrations
    class TeachingPreferencesController < RegistrationsController
      def new
        @teaching_preference = \
          current_registration.build_teaching_preference attributes_from_session
      end

      def create
        @teaching_preference = \
          current_registration.build_teaching_preference teaching_preference_params

        if @teaching_preference.save
          redirect_to next_step_path
        else
          render :new
        end
      end

      def edit
        @teaching_preference = current_registration.teaching_preference
      end

      def update
        @teaching_preference = current_registration.teaching_preference

        if @teaching_preference.update teaching_preference_params
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def teaching_preference_params
        params.require(:candidates_registrations_teaching_preference).permit \
          :teaching_stage,
          :subject_first_choice,
          :subject_second_choice
      end

      def attributes_from_session
        current_registration.teaching_preference_attributes
      end
    end
  end
end
