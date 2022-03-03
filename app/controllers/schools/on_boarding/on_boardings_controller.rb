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
        unless school_profile.lite_completed?
          next_step = school_profile.current_step_lite

        else
          last_step = request.path.split("/").last.to_sym
          next_step = school_profile.current_step(last_step)
        end

        if next_step
          public_send "new_schools_on_boarding_#{next_step}_path"
        else
          schools_on_boarding_progress_path
        end
      end

      def continue(school_profile)
        if current_school.onboarded? && school_profile.completed?
          Bookings::ProfilePublisher.new(current_school, school_profile).update!
          flash.notice = "Your profile has been saved and published."
        end

        redirect_to next_step_path(current_school_profile)
      end
    end
  end
end
