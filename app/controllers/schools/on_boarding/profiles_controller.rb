module Schools
  module OnBoarding
    class ProfilesController < OnBoardingsController
      before_action do
        current_school_profile
      end

      def show
        @profile = SchoolProfilePresenter.new(current_school_profile)
        @confirmation = Confirmation.new
      end
    end
  end
end
