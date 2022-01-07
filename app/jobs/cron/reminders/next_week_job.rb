module Cron
  module Reminders
    class NextWeekJob < CronJob
      self.cron_expression = '35 9 * * *'

      def perform
        return true unless Feature.active? :reminders

        bookings.all? do |booking|
          Bookings::ReminderJob.perform_later(booking, time_until_booking, time_until_booking_descriptive)
        end
      end

      def bookings
        Bookings::Booking.not_cancelled.accepted.for_one_week_from_now
      end

      # this string will be used in the email subject, something along the lines
      # of "Your School Experience placement at {some school} is in {one week}"
      def time_until_booking
        "one week"
      end

      # This will be used for SMS messages in the format: "Your school experience
      # is {time_until_booking_descriptive}". Its a bit more awkward than the
      # time_until_booking, but reads nicer.
      def time_until_booking_descriptive
        "in one week"
      end
    end
  end
end
