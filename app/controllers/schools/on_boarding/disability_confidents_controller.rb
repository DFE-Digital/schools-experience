module Schools
  module OnBoarding
    class DisabilityConfidentsController < OnBoardingsController
      def new
        @disability_confident = DisabilityConfident.new
      end

      def create
        @disability_confident = DisabilityConfident.new \
          disability_confident_params

        if @disability_confident.valid?
          current_school_profile.update! \
            disability_confident: @disability_confident

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def disability_confident_params
        params.require(:schools_on_boarding_disability_confident).permit \
          :is_disability_confident
      end
    end
  end
end
