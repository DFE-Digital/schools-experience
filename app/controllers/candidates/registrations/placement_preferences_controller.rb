module Candidates
  module Registrations
    class PlacementPreferencesController < RegistrationsController
      def new
        @placement_preference = PlacementPreference.new
      end

      def create
        @placement_preference = PlacementPreference.new placement_preference_params
        if @placement_preference.valid?
          persist @placement_preference
          redirect_to new_candidates_school_registrations_account_check_path
        else
          render :new
        end
      end

    private

      def placement_preference_params
        params.require(:candidates_registrations_placement_preference).permit \
          :date_start,
          :date_end,
          :objectives,
          :access_needs,
          :access_needs_details
      end
    end
  end
end
