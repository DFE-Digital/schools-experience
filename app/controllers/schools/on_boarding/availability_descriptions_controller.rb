module Schools
  module OnBoarding
    class AvailabilityDescriptionsController < OnBoardingsController
      def new
        @availability_description = AvailabilityDescription.new
      end

      def create
        @availability_description = AvailabilityDescription.new \
          availability_description_params

        if @availability_description.valid?
          current_school_profile.update! \
            availability_description: @availability_description

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @availability_description = current_school_profile.availability_description
      end

      def update
        @availability_description = AvailabilityDescription.new \
          availability_description_params

        if @availability_description.valid?
          current_school_profile.update! \
            availability_description: @availability_description

          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def availability_description_params
        params.require(:schools_on_boarding_availability_description).permit \
          :description
      end
    end
  end
end
