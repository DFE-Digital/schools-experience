module Candidates
  module Registrations
    class PlacementPreferencesController < RegistrationsController
      def new
        @placement_preference = PlacementPreference.new \
          attributes_from_session.merge(urn: current_urn)
      end

      def create
        @placement_preference = PlacementPreference.new \
          placement_preference_params

        if @placement_preference.valid?
          persist @placement_preference
          redirect_to next_step_path
        else
          render :new
        end
      end

      def edit
        @placement_preference = current_registration.placement_preference
      end

      def update
        @placement_preference = current_registration.placement_preference
        @placement_preference.assign_attributes placement_preference_params

        if @placement_preference.valid?
          persist @placement_preference
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def placement_preference_params
        params.require(:candidates_registrations_placement_preference).permit(
          :objectives,
          :bookings_placement_date_id
        ).merge(urn: current_urn)
      end

      def attributes_from_session
        current_registration.placement_preference_attributes.except 'created_at'
      end
    end
  end
end
