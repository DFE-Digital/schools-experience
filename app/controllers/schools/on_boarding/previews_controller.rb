module Schools
  module OnBoarding
    class PreviewsController < OnBoardingsController
      include MapsContentSecurityPolicy

      before_action do
        unless current_school_profile.completed?
          continue(current_school_profile)
        end
      end

      def show
        @school = current_school_profile.bookings_school
        @presenter = PreviewPresenter.new current_school_profile
      end
    end
  end
end
