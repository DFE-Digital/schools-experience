module Schools
  module OnBoarding
    class DescriptionsController < OnBoardingsController
      def new
        @description = Description.new
      end

      def create
        @description = Description.new description_params

        if @description.valid?
          current_school_profile.update! description: @description
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @description = current_school_profile.description
      end

      def update
        @description = Description.new description_params

        if @description.valid?
          current_school_profile.update! description: @description
          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def description_params
        params.require(:schools_on_boarding_description).permit :details
      end
    end
  end
end
