module Cron
  module Reminders
    class Tomorrow < CronJob
      self.cron_expression = '30 2 * * *'

      # Create one Bookings::ReminderBuilder task _per booking_, each
      # Bookings::ReminderBuilder, via Bookings::Reminder is responsible
      # for pulling its own information (name, email) from Gitis and should
      # individually retry if the API isn't available
      def perform
        bookings.each do |booking|
          Bookings::ReminderBuilder.perform_later(booking, time_until_booking)
        end
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
