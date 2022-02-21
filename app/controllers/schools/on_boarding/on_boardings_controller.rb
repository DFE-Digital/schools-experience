module Schools
  module OnBoarding
    class OnBoardingsController < BaseController
      skip_before_action :ensure_onboarded

    private

      def current_school_profile
        @current_school_profile ||= get_current_school_profile
      end

      def get_current_school_profile
        current_school.school_profile || current_school.create_school_profile!
      end

      def next_step_path(school_profile)
        if school_profile.completed?
          schools_on_boarding_profile_path
        else
          public_send "new_schools_on_boarding_#{school_profile.current_step}_path"
        end
      end

      def continue(school_profile)
        if current_school.private_beta? && school_profile.completed?
          Bookings::ProfilePublisher.new(current_school, school_profile).update!
          flash.notice = "Your profile has been saved and published."
        end

        redirect_to next_step_path(current_school_profile)
      end
    end
  end
end
