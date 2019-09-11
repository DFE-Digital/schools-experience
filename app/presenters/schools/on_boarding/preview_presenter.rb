module Schools
  module OnBoarding
    class PreviewPresenter
      delegate_missing_to :candidate_school_presenter

      def initialize(on_boarding_profile)
        @on_boarding_profile = on_boarding_profile
      end

      def school
        @school ||= @on_boarding_profile.bookings_school.tap do |s|
          s.phase_ids   = converter.phase_ids
          s.subject_ids = @on_boarding_profile.subject_ids
        end
      end

    private

      def candidate_school_presenter
        @candidate_school_presenter ||= Candidates::SchoolPresenter.new \
          school, bookings_profile
      end

      def converter
        @converter ||= Bookings::ProfileAttributesConvertor.new \
          @on_boarding_profile.attributes
      end

      def bookings_profile
        @bookings_profile ||= Bookings::Profile.new converter.attributes
      end
    end
  end
end
