module Candidates
  module Registrations
    class EducationsController < RegistrationsController
      def new
        @education = Education.new attributes_from_session
      end

      def create
        @education = Education.new education_params

        if @education.valid?
          persist @education
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
        @education.assign_attributes education_params

        if @education.valid?
          persist @education
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def education_params
        params.require(:candidates_registrations_education).permit(
          :degree_stage,
          :degree_stage_explaination,
          :degree_subject
        ).tap do |params|
          params[:degree_stage_explaination] = nil unless params[:degree_stage] == 'Other'
        end
      end

      def attributes_from_session
        current_registration.education_attributes.except 'created_at'
      end
    end
  end
end
