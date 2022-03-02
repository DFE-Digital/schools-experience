module Schools
  module OnBoarding
    class ProgressesController < OnBoardingsController
      def show
        @current_step = OnBoarding::CurrentStep.new(current_school_profile)
      end
    end
  end
end
