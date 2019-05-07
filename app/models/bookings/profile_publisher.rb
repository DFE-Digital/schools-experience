module Bookings
  class ProfilePublisher
    def initialize(urn_or_school, school_profile)
      @urn_or_school = urn_or_school
      @school_profile = school_profile

      unless @school_profile.completed?
        raise IncompleteSourceProfileError
      end
    end

    def update!
      profile.transaction do
        profile.attributes = converted_attributes
        school.subject_ids = @school_profile.subject_ids
        profile.tap(&:save!)
      end
    end

    class IncompleteSourceProfileError < RuntimeError; end

  private

    def school
      @school ||= \
        if @urn_or_school.is_a?(Bookings::School)
          @urn_or_school
        else
          Bookings::School.find_by!(urn: urn_or_school)
        end
    end

    def converted_attributes
      @converted_attributes ||= \
        ProfileAttributesConvertor.new(@school_profile.attributes).attributes
    end

    def profile
      school.build_profile unless school.profile

      school.profile
    end
  end
end
