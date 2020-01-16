module Cron
  module Reminders
    class NextWeekJob < CronJob
      self.cron_expression = '35 2 * * *'

      def perform
        bookings.all? do |booking|
          Bookings::ReminderBuilder.perform_later(booking, time_until_booking)
        end
      end

      def bookings
        Bookings::Booking.not_cancelled.one_week_from_now
      end

      # this string will be used in the email subject, something along the lines
      # of "Your School Experience placement at {some school} is in {one week}"
      def time_until_booking
        "one week"
      end
    end
  end
end
