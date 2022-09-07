module Schools
  module OnBoarding
    class ProgressesController < OnBoardingsController
      def show
        @wizard = OnBoarding::Wizard.new(current_school_profile)
      end
    end
  end
end
