module Schools
  module OnBoarding
    class ProfilesController < OnBoardingsController
      before_action do
        unless current_school_profile.completed?
          redirect_to next_step_path(current_school_profile)
        end
      end

      def show
        @confirmation = Confirmation.new
        @profile = SchoolProfilePresenter.new(current_school_profile)

        render @current_school.onboarded? ? :editing : :onboarding
      end
    end
  end
end
