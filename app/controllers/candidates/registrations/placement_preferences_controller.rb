module Candidates
  module Registrations
    class PlacementPreferencesController < RegistrationsController
      before_action :set_school, :set_placement_dates

      def new
        @placement_preference = \
          current_registration.build_placement_preference attributes_from_session
      end

      def create
        @placement_preference = \
          current_registration.build_placement_preference placement_preference_params

        if @placement_preference.save
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

        if @placement_preference.update placement_preference_params
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def set_school
        @school = current_registration.school
      end

      def set_placement_dates
        if @school.availability_preference_fixed?
          @placement_dates = @school
            .bookings_placement_dates
            .published
            .available
        end
      end

      def placement_preference_params
        params.require(:candidates_registrations_placement_preference).permit \
          :availability,
          :objectives,
          :bookings_placement_date_id
      end

      def attributes_from_session
        current_registration.placement_preference_attributes.except 'created_at'
      end
    end
  end
end
