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
      end

      def publish
        if current_school.private_beta?
          Bookings::ProfilePublisher.new(current_school, current_school_profile).update!
        end

        redirect_to schools_on_boarding_confirmation_path
      end
    end
  end
end
