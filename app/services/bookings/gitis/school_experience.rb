module Bookings
  module Gitis
    # Creates a new 'Candidate School Experience' entity in Gitis. We should create a new
    # entity when the status of the school experience changes.
    class SchoolExperience
      include ActiveModel::Validations

      private_class_method :new

      # requested: placement requested by candidate
      # confirmed: placement request accepted by school
      # withdrawn: candidate didn't attend placement
      # rejected: request rejected by school
      # cancelled_by_school: cancelled by school
      # cancelled_by_candidate: cancelled by candidate
      # completed: candidate attended placement
      GITIS_STATUS = {
        requested: 1,
        confirmed: 222_750_000,
        withdrawn: 222_750_001,
        rejected: 222_750_002,
        cancelled_by_school: 222_750_003,
        cancelled_by_candidate: 222_750_004,
        completed: 222_750_005
      }.freeze.with_indifferent_access

      attr_reader :date, :urn, :school_name, :teaching_subject_name, :duration, :status

      validates :urn, length: { maximum: 8 }
      validates :duration, numericality: { less_than_or_equal_to: 100 }, allow_nil: true
      validates :school_name, length: { maximum: 100 }
      validates :status, inclusion: { in: GITIS_STATUS.symbolize_keys.keys }

      class << self
        def from_placement_request(request, status)
          new(
            date: request.placement_date&.date,
            urn: request.school.urn,
            school_name: request.school.name,
            teaching_subject_name: request.subject_first_choice,
            duration: request.placement_date&.duration,
            status: status
          )
        end

        def from_booking(booking, status)
          new(
            date: booking.date,
            urn: booking.bookings_school.urn,
            school_name: booking.bookings_school.name,
            teaching_subject_name: booking.bookings_subject.name,
            duration: booking.duration,
            status: status
          )
        end

        def from_cancellation(cancellation, status)
          new(
            date: (cancellation.booking || cancellation.placement_request.placement_date)&.date,
            urn: cancellation.school_urn,
            school_name: cancellation.school_name,
            teaching_subject_name: (cancellation.booking&.bookings_subject&.name || cancellation.placement_request.subject_first_choice),
            duration: (cancellation.booking || cancellation.placement_request.placement_date)&.duration,
            status: status
          )
        end
      end

      def write_to_gitis_contact(contact_id)
        api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
        api.add_school_experience(contact_id, gitis_school_experience)
      end

    private

      def initialize(date:, urn:, school_name:, teaching_subject_name:, duration:, status:)
        @date = date
        @urn = urn.to_s
        @school_name = school_name
        @teaching_subject_name = teaching_subject_name
        @duration = duration
        @status = status

        validate!
      end

      def gitis_school_experience
        GetIntoTeachingApiClient::CandidateSchoolExperience.new(
          school_urn: @urn,
          duration_of_placement_in_days: @duration,
          date_of_school_experience: @date,
          status: GITIS_STATUS[@status],
          teaching_subject_id: Bookings::Gitis::SubjectFetcher.api_subject_id_from_gitis_value(@teaching_subject_name),
          school_name: @school_name
        )
      end
    end
  end
end
