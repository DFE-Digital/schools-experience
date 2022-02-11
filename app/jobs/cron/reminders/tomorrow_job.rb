module Cron
  module Reminders
    class TomorrowJob < CronJob
      self.cron_expression = '30 9 * * *'

      # Create one Bookings::ReminderJob _per booking_, each
      # Bookings::ReminderJob, via Bookings::Reminder is responsible
      # for pulling its own information (name, email) from Gitis and should
      # individually retry if the API isn't available
      def perform
        return true unless Feature.enabled? :reminders

        bookings.each do |booking|
          Bookings::ReminderJob.perform_later(booking, time_until_booking, time_until_booking_descriptive)
        end
      end

      def bookings
        Bookings::Booking.not_cancelled.accepted.for_tomorrow
      end

      # this string will be used in the email subject, something along the lines
      # of "Your School Experience placement at {some school} is in {one day}"
      def time_until_booking
        "one day"
      end

      # This will be used for SMS messages in the format: "Your school experience
      # is {time_until_booking_descriptive}". Its a bit more awkward than the
      # time_until_booking, but reads nicer.
      def time_until_booking_descriptive
        "tomorrow"
      end
    end
  end
end
