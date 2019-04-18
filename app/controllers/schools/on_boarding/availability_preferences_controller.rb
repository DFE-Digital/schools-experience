module Schools
  module OnBoarding
    class AvailabilityPreferencesController < OnBoardingsController
      def new
        @availability_preference = AvailabilityPreference.new
      end

      def create
        @availability_preference = \
          AvailabilityPreference.new availability_preference_params

        if @availability_preference.valid?
          current_school_profile.update! \
            availability_preference: @availability_preference

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def availability_preference_params
        params.require(:schools_on_boarding_availability_preference).permit \
          :fixed
      end
    end
  end
end
