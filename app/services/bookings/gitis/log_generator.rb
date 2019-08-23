module Bookings
  module Gitis
    class LogGenerator
      attr_reader :type, :subject

      NOTES_HEADER = "RECORDED   ACTION     EXPERIENCE  URN     NAME".freeze

      def self.entry(type, subject)
        new(type, subject).entry
      end

      def initialize(type, subject)
        @type = type
        @subject = subject
      end

      def entry
        send(:"generate_#{type}_entry")
      end

    private

      def generate_request_entry
        log_line \
          subject.requested_on.to_formatted_s(:gitis),
          'REQUEST',
          subject.placement_date&.date&.to_formatted_s(:gitis), # return nil for flexible dates
          subject.school.urn,
          subject.school.name
      end

      def generate_booking_entry
        log_line \
          subject.accepted_at.to_formatted_s(:gitis),
          'ACCEPTED',
          subject.date.to_formatted_s(:gitis), # return nil for flexible dates
          subject.bookings_school.urn,
          subject.bookings_school.name
      end

      def generate_cancellation_entry
        log_line \
          subject.sent_at.to_date.to_formatted_s(:gitis),
          "CANCELLED BY #{subject.cancelled_by.upcase}",
          (subject.booking || subject.placement_request.placement_date) \
            &.date&.to_formatted_s(:gitis),
          subject.school_urn,
          subject.school_name
      end

      def generate_attendance_entry
        log_line \
          subject.accepted_at.to_formatted_s(:gitis),
          subject.attended? ? 'ATTENDED' : 'DID NOT ATTEND',
          subject.date.to_formatted_s(:gitis), # return nil for flexible dates
          subject.bookings_school.urn,
          subject.bookings_school.name
      end

      def log_line(recorded, action, experience_date, urn, schoolname)
        recorded = Date.parse(recorded) if recorded.is_a?(String)
        recorded = recorded.to_date.to_formatted_s(:gitis)

        experience_date = if experience_date.nil?
                            '        '
                          elsif experience_date.is_a?(String)
                            Date.parse(experience_date).to_formatted_s(:gitis)
                          else
                            experience_date.to_date.to_formatted_s(:gitis)
                          end

        "%8<recorded>s %-22<action>s %8<date>s %<urn>s %<name>s" % {
          recorded: recorded,
          action: action.to_s.upcase,
          date: experience_date,
          urn: urn,
          name: schoolname
        }
      end
    end
  end
end
