module Schools
  module OnBoarding
    class OnBoardingsController < BaseController
    private

      def current_school_profile
        @current_school_profile ||= get_current_school_profile
      end

      def get_current_school_profile
        Schools::SchoolProfile.find_or_create_by! urn: current_school.urn
      end

      def next_step_path(school_profile)
        current_step = CurrentStep.for school_profile

        if current_step == :COMPLETED
          schools_on_boarding_profile_path
        else
          public_send "new_schools_on_boarding_#{current_step}_path"
        end
      end
    end
  end
end
