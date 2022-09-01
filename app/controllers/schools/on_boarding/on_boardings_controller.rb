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
        if Feature.enabled?(:task_progress_on_boarding)
          task_progress_next_step_path(school_profile)
        else
          return schools_on_boarding_profile_path if school_profile.completed?

          public_send("new_schools_on_boarding_#{school_profile.current_step}_path")
        end
      end

      def task_progress_next_step_path(school_profile)
        previous_step = request.path.split("/").last.to_sym
        next_step = school_profile.current_step(previous_step)

        if next_step
          public_send("new_schools_on_boarding_#{next_step}_path")
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
