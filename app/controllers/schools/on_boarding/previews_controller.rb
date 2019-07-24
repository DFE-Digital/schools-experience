module Schools
  module OnBoarding
    class PreviewsController < OnBoardingsController
      before_action do
        unless current_school_profile.completed?
          redirect_to next_step_path(current_school_profile)
        end
      end

      def show
        @school = current_school_profile.bookings_school
        @confirmation = Confirmation.new
        @presenter = PreviewPresenter.new current_school_profile
      end
    end
  end
end
