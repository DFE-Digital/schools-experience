module Bookings
  module Gitis
    class EventLogger
      attr_reader :type, :subject

      NOTES_HEADER = "RECORDED   ACTION                 EXP DATE   URN    NAME".freeze
      LOG_LINE = "%10<recorded>s %-22<action>s %8<date>s %-6<urn>s %<name>s".freeze

      class << self
        def entry(type, subject)
          new(type, subject).entry
        end

        def write_later(contactid, type, subject)
          Bookings::LogToGitisJob.perform_later \
            contactid, new(type, subject).entry
        end
      end

      def initialize(type, subject)
        @subject = subject
        send(:"parse_#{type}_entry")
      end

      def entry
        LOG_LINE % {
          recorded: @recorded,
          action: @action,
          date: @date,
          urn: @urn,
          name: @name
        }
      end

    private

      def parse_request_entry
        @recorded = subject.requested_on.to_formatted_s(:gitis)
        @action   = 'REQUEST'
        @date     = subject.placement_date&.date&.to_formatted_s(:gitis)
        @urn      = subject.school.urn
        @name     = subject.school.name
      end

      def parse_booking_entry
        @recorded = subject.accepted_at.to_date.to_formatted_s(:gitis)
        @action   = 'ACCEPTED'
        @date     = subject.date.to_formatted_s(:gitis)
        @urn      = subject.bookings_school.urn
        @name     = subject.bookings_school.name
      end

      def parse_cancellation_entry
        datesrc = (subject.booking || subject.placement_request.placement_date)

        @recorded = subject.sent_at.to_date.to_formatted_s(:gitis)
        @action   = "CANCELLED BY #{subject.cancelled_by.upcase}"
        @date     = datesrc&.date&.to_formatted_s(:gitis)
        @urn      = subject.school_urn
        @name     = subject.school_name
      end

      def parse_attendance_entry
        @recorded = subject.accepted_at.to_date.to_formatted_s(:gitis)
        @action   = subject.attended? ? 'ATTENDED' : 'DID NOT ATTEND'
        @date     = subject.date.to_formatted_s(:gitis)
        @urn      = subject.bookings_school.urn
        @name     = subject.bookings_school.name
      end
    end
  end
end
