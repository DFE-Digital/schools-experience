module Schools
  module OnBoarding
    class ProfilesController < OnBoardingsController
      def show
        @profile = SchoolProfilePresenter.new(current_school_profile)
        @confirmation = Confirmation.new
      end
    end
  end
end
