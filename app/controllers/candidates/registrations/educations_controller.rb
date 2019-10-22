module Candidates
  module Registrations
    class EducationsController < RegistrationsController
      def new
        @education = current_registration.build_education attributes_from_session
      end

      def create
        @education = current_registration.build_education education_params

        if @education.save
          redirect_to next_step_path
        else
          render :new
        end
      end

      def edit
        @education = current_registration.education
      end

      def update
        @education = current_registration.education

        if @education.update education_params
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def education_params
        params.require(:candidates_registrations_education).permit \
          :degree_stage,
          :degree_stage_explaination,
          :degree_subject
      end

      def attributes_from_session
        current_registration.education_attributes.except 'created_at'
      end
    end
  end
end
