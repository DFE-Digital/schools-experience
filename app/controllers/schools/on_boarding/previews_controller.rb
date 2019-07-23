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
        set_up_school_for_preview! @school

        profile = Bookings::Profile.new converter.attributes
        @presenter = Candidates::SchoolPresenter.new @school, profile
        @confirmation = Confirmation.new
      end

    private

      def set_up_school_for_preview!(school)
        school.phase_ids = converter.phase_ids
        school.subject_ids = current_school_profile.subject_ids
      end

      def converter
        @converter ||= Bookings::ProfileAttributesConvertor.new current_school_profile.attributes
      end
    end
  end
end
