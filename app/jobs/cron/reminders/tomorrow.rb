module Cron
  module Reminders
    class Tomorrow < CronJob
      self.cron_expression = '30 2 * * *'

      def perform
        Bookings::Reminder.new(time_until_booking, bookings).enqueue
      end

      def bookings
        Bookings::Booking.not_cancelled.tomorrow
      end

      # this string will be used in the email subject, something along the lines
      # of "Your School Experience placement at {some school} is in {one day}"
      def time_until_booking
        "one day"
      end
    end
  end
end
