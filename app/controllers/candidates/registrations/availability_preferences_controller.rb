module Candidates
  module Registrations
    class AvailabilityPreferencesController < RegistrationsController
      before_action :set_school

      def new
        @availability_preference = AvailabilityPreference.new \
          attributes_from_session.merge(urn: current_urn)
      end

      def create
        @availability_preference = AvailabilityPreference.new \
          availability_preference_params

        if @availability_preference.valid?
          persist @availability_preference
          redirect_to next_step_path
        else
          render :new
        end
      end

      def edit
        @availability_preference = current_registration.availability_preference
      end

      def update
        @availability_preference = current_registration.availability_preference
        @availability_preference.assign_attributes availability_preference_params

        if @availability_preference.valid?
          persist @availability_preference
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def set_school
        @school = current_registration.school
      end

      def availability_preference_params
        params.require(:candidates_registrations_availability_preference).permit(
          :availability
        ).merge(urn: current_urn)
      end

      def attributes_from_session
        current_registration.availability_preference_attributes.except 'created_at'
      end
    end
  end
end
