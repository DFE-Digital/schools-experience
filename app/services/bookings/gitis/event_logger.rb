module Bookings
  module Gitis
    class EventLogger
      attr_reader :type, :subject

      NOTES_HEADER = "RECORDED   ACTION                 EXP DATE   URN    NAME".freeze
      LOG_LINE = "%10<recorded>s %-22<action>s %10<date>s %-6<urn>s %.25<name>s".freeze

      class << self
        def entry(type, subject)
          new(type, subject).entry
        end

        def write_later(contactid, type, subject)
          instance = new(type, subject)

          api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
          api.add_classroom_experience_note(contactid, instance.classroom_experience_note)
        end
      end

      def initialize(type, subject)
        @subject = subject
        send(:"parse_#{type}_entry")
      end

      def entry
        sprintf(LOG_LINE, recorded: @recorded_str, action: @action, date: @date_str, urn: @urn, name: @name)
      end

      def classroom_experience_note
        GetIntoTeachingApiClient::ClassroomExperienceNote.new(
          recorded_at: @recorded_date,
          action: @action,
          date: @date,
          school_urn: @urn,
          school_name: @name,
        )
      end

    private

      def parse_request_entry
        @recorded_date = subject.requested_on
        @date = subject.placement_date&.date

        @recorded_str = @recorded_date.to_formatted_s(:gitis)
        @action       = 'REQUEST'
        @date_str     = @date&.to_formatted_s(:gitis)
        @urn          = subject.school.urn
        @name         = subject.school.name
      end

      def parse_booking_entry
        @recorded_date = subject.accepted_at.to_date
        @date = subject.date

        @recorded_str = @recorded_date.to_formatted_s(:gitis)
        @action = 'ACCEPTED'
        @date_str = @date.to_formatted_s(:gitis)
        @urn = subject.bookings_school.urn
        @name = subject.bookings_school.name
      end

      def parse_cancellation_entry
        @recorded_date = subject.sent_at.to_date
        datesrc = (subject.booking || subject.placement_request.placement_date)
        @date = datesrc&.date

        @recorded_str = @recorded_date.to_formatted_s(:gitis)
        @action       = "CANCELLED BY #{subject.cancelled_by.upcase}"
        @date_str     = @date&.to_formatted_s(:gitis)
        @urn          = subject.school_urn
        @name         = subject.school_name
      end

      def parse_attendance_entry
        @recorded_date = subject.accepted_at.to_date
        @date = subject.date

        @recorded_str = @recorded_date.to_formatted_s(:gitis)
        @action       = subject.attended? ? 'ATTENDED' : 'DID NOT ATTEND'
        @date_str     = @date.to_formatted_s(:gitis)
        @urn          = subject.bookings_school.urn
        @name         = subject.bookings_school.name
      end
    end
  end
end
