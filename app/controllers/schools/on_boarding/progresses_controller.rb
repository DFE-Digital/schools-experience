module Schools
  module OnBoarding
    class ProgressesController < OnBoardingsController
      def show
        @profile = current_school_profile
        @presenter = SchoolProfilePresenter.new(@profile)
        @current_step = OnBoarding::CurrentStep.new(current_school_profile)
      end
    end
  end
end
