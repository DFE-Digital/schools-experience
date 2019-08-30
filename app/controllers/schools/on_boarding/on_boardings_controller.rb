module Schools
  module OnBoarding
    class OnBoardingsController < BaseController
      skip_before_action :ensure_onboarded

    private

      def current_school_profile
        @current_school_profile ||= get_current_school_profile
      end

      def get_current_school_profile
        current_school.school_profile || create_school_profile!
      end

      def create_school_profile!
        current_school.create_school_profile! \
          show_candidate_requirements_selection: show_candidate_requirements_selection?
      end

      def show_candidate_requirements_selection?
        return false unless Feature.instance.active? :candidate_requirement_ab_test

        Random.rand(100) <= Rails.application.config.ab_threshold
      end

      def next_step_path(school_profile)
        if school_profile.completed?
          schools_on_boarding_profile_path
        else
          public_send "new_schools_on_boarding_#{school_profile.current_step}_path"
        end
      end
    end
  end
end
